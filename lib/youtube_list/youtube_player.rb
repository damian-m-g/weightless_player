# An instance of this class knows how to reproduce music passed as argument in YouTube. Internet connection is needed.
class YouTubePlayer

  YOUTUBE_URL = 'https://www.youtube.com/'
  DATA_LOCATION = "#{File.dirname(File.dirname(File.dirname(__FILE__)))}/data"
  ADBLOCK_LOCATION = "#{DATA_LOCATION}/adblockpluschrome.crx"
  CHROMEDRIVER_LOCATION = "#{DATA_LOCATION}/chromedriver.exe"
  TARGET_CHROMEDRIVER_PLACEMENT = "#{ENV['APPDATA'].gsub('\\', '/')}/JorobusLab/YouTubeLister"
  AMOUNT_OF_PLAYABLES_TO_INSPECT = 3
  SEARCH_BUTTON_IDENTIFICATION = {key: :id, value: 'search-icon-legacy'}
  SONG_TITLE_IDENTIFICATION = {key: :id, value: 'title-wrapper'}
  # minutes from where a playable item is recognized as an album
  KNOWN_AS_SONG_LIMIT = 20

  attr_writer :song_list

  # Initializes the browser instance, hidding it.
  def initialize
    place_chromedriver_in_c()
    add_chromedriver_to_path()
    # we don't want undesirable logs
    logger = Selenium::WebDriver.logger
    logger.level = :fatal
    logger.output = "#{TARGET_CHROMEDRIVER_PLACEMENT}/log.log"
    # set and start the browser
    args = ['disable-infobars']
    options = Selenium::WebDriver::Chrome::Options.new(args: args)
    options.add_extension(ADBLOCK_LOCATION)
    webdriver = Selenium::WebDriver.for(:chrome, options: options)
    # move the window out of sight as quick as you can
    point = Selenium::WebDriver::Point.new(-4000, 0)
    webdriver.manage.window.position = point
    @browser = Watir::Browser.start(YOUTUBE_URL, webdriver)
    # there could be more than one windows (tabs) opened, let just one on top
    if(@browser.windows.size > 1)
      @browser.windows.last.close
      @browser.windows.first.use
    end
    # give some time for the tab to get closed
    sleep(0.5)
    # use autoit to hide some windows (nor in the bar will appear)
    @au3 = AutoItX3.new
    # hide the chromedriver.exe console output, if appeared
    @au3.hide_chromedriver_console rescue nil
    # hide the browser
    @au3.hide_browser
    # wait for a moment so the page gets loaded
    sleep(0.25)
  end

  # Opens Chrome instance, travel to YouTube, seek for songs, and reproduce them.
  def play_songs
    @song_list.each do |song|
      play_song(song)
    end
  end

  # @param song [Song], @param volume [Float]. @return [TrueClass or FalseClass]. Returns false if the song wasn't found, true if was successfully played, when finished playing it. *volume* must be a value between 0 and 1.
  def play_song(song, volume)
    # travel to YouTube if not there yet
    if(!@browser.url.match('youtube')) then(@browser.goto(YOUTUBE_URL)) end
    # check if important elements are loaded, otherwise wait for them
    ready = false
    until(ready)
      if(@browser.text_field.visible? rescue nil)
        ready = true
        sleep(0.75)
      end
    end
    # the song is formatted with a '-' dividing artist and song, format it accordly for this task. Try to get HQ song first
    string_for_searcher_hq = get_string_for_searcher(song, hq: true) #: String
    @browser.text_field.value = string_for_searcher_hq #: String
    @browser.button(SEARCH_BUTTON_IDENTIFICATION[:key], SEARCH_BUTTON_IDENTIFICATION[:value]).click
    # wait until important elements gets loaded
    ready = false
    until(ready)
      tries = 0
      begin
        sleep(0.5)
        divs = @browser.divs(SONG_TITLE_IDENTIFICATION[:key], SONG_TITLE_IDENTIFICATION[:value]).to_a
      rescue
        if(tries == 0)
          sleep(0.5)
          tries += 1
          retry
        else
          @browser.refresh
          _ready = false
          until(_ready)
            if(@browser.text_field.visible? rescue nil)
              _ready = true
              sleep(0.75)
            end
          end
          tries += 1
          retry
        end
      end
      if((divs.size >= 3) && (divs[2].visible?))
        ready = true
        sleep(0.25)
      end
    end
    # first three titles are really needed
    divs = divs.first(AMOUNT_OF_PLAYABLES_TO_INSPECT)
    # try to find a proper hq playable
    proper_playable = find_proper_playable(song, divs) #: Fixnum or NilClass
    if(proper_playable)
      # play it
      divs[proper_playable].click
      # disable automatic reproduction if needed
      if(!@automatic_reproduction_disabled)
        sleep(0.75)
        @browser.div(:id, 'toggleButton').click
        @automatic_reproduction_disabled = true
        # control volume
        sleep(0.5)
        set_player_volume(volume)
      else
        sleep(1.25)
        # control volume
        set_player_volume(volume)
      end
    else
      # try to find just a proper playable
      string_for_searcher = get_string_for_searcher(song, hq: false) #: String
      @browser.text_field.value = string_for_searcher #: String
      @browser.button(SEARCH_BUTTON_IDENTIFICATION[:key], SEARCH_BUTTON_IDENTIFICATION[:value]).click
      # wait until important elements gets loaded
      ready = false
      until(ready)
        tries = 0
        begin
          sleep(0.5)
          divs = @browser.divs(SONG_TITLE_IDENTIFICATION[:key], SONG_TITLE_IDENTIFICATION[:value]).to_a
        rescue
          if(tries == 0)
            sleep(0.5)
            tries += 1
            retry
          else
            @browser.refresh
            _ready = false
            until(_ready)
              if(@browser.text_field.visible? rescue nil)
                _ready = true
                sleep(0.75)
              end
            end
            tries += 1
            retry
          end
        end
        if((divs.size >= 3) && (divs[2].visible?))
          ready = true
          sleep(0.25)
        end
      end
      # get first three titles
      divs = divs.first(AMOUNT_OF_PLAYABLES_TO_INSPECT)
      proper_playable = find_proper_playable(song, divs) #: Fixnum or NilClass
      if(proper_playable)
        # play it
        divs[proper_playable].click
        # disable automatic reproduction if needed
        if(!@automatic_reproduction_disabled)
          sleep(0.75)
          @browser.div(:id, 'toggleButton').click
          @automatic_reproduction_disabled = true
          # control volume
          sleep(0.5)
          set_player_volume(volume)
        else
          sleep(1.25)
          # control volume
          set_player_volume(volume)
        end
      else
        # woops, no song found, go with the next one
        return(false)
      end
    end
    true
  end

  # @param @return [TrueClass or Falseclass]. Check the progress of the current song, if there's one being played. Returns true if has ended, false otherwise.
  def do_the_song_finished_playing?
    # find the progress bar if not found yet
    if(!@progress_bar)
      @progress_bar = @browser.element(:class, 'ytp-play-progress') rescue nil
    end
    # inspect the progress bar, if found
    if(@progress_bar && @progress_bar.style.match(/transform: scaleX\(1\)/))
      true
    else
      false
    end
  end

  # Touches the play/pause button on the YT palyer, if found.
  def touch_play_pause_button
    @browser.button(:class, 'ytp-play-button').click
    true
  rescue
    false
  end

  # WARNING: For some reasson, sometimes the volume go up from nowhere. That's why currently is being refreshed every 0.35 seconds from the #GUI.
  # @param volume [Float]. *volume* must be a value between 0 and 1.
  def set_player_volume(volume = nil)
    @browser.execute_script("return arguments[0].volume = #{@volume = volume || @volume}", @browser.video)
  end

  private

  # @param song [Song], @param titles [Array]. @return [Fixnum or NilClass]. Find a proper playable for a specific *song* among several *titles*. Note that *titles* are "h3" elements gathered by Watir.
  def find_proper_playable(song, titles)
    titles.each_with_index do |title, index|
      title_text = title.text
      if((title_text.match(Regexp.new(Regexp.escape(song.artist), true))) && (title_text.match(Regexp.new(Regexp.escape(song.song), true))))
        # looks like the song artist and the name of the song is on the title, see if "live" (and else) isn't included
        if((!((!(song.artist.match(/live/i))) && (!(song.song.match(/live/i))) && (title_text.match(/live/i)))) && (!(title_text.match(/(?:(?:\d{1,2}[\/-]\d{1,2}[\/-]\d{2,4})|(?:\d{2,4}[\/-]\d{1,2}[\/-]\d{1,2}))/))))
          # everything is good by now, check if the title doesn't belong to an album
          _duration = title.parent.parent.parent.span.text rescue nil #: String
          match = _duration.match(/(?:(\d{0,2}):)?(\d{1,2}):(\d{2})\z/) #: Integer or NilClass
          if(match)
            total_minutes = 0
            hours_as_minutes = ((match[1] != nil) && (match[1] != '')) ? (Integer(match[1]) * 60) : 0
            total_minutes += hours_as_minutes
            minutes = Integer(match[2])
            total_minutes += minutes
            if(total_minutes && (total_minutes <= KNOWN_AS_SONG_LIMIT))
              # perfect, a playable has matched the requirements
              return(index)
            end
          end
        end
      end
    end
    nil
  end

  # @param string [Song], @param hq [TrueClass or FalseClass]. @return [String].
  def get_string_for_searcher(song, hq: true)
    string_for_searcher = song.to_s.gsub('-', '+')
    if(hq) then(string_for_searcher.<<(' + HQ')) end
    string_for_searcher #: String
  end

  def add_chromedriver_to_path
    ENV['Path'] = "#{ENV['Path']};#{TARGET_CHROMEDRIVER_PLACEMENT.gsub('/', '\\')}"
  end

  def place_chromedriver_in_c
    if(!(Dir.exists?(File.dirname(TARGET_CHROMEDRIVER_PLACEMENT)))) then(Dir.mkdir(File.dirname(TARGET_CHROMEDRIVER_PLACEMENT))) end
    if(!(Dir.exists?(TARGET_CHROMEDRIVER_PLACEMENT))) then(Dir.mkdir(TARGET_CHROMEDRIVER_PLACEMENT)) end
    # erase any previous chromedriver version
    if(!(File.exists?(target_placement = "#{TARGET_CHROMEDRIVER_PLACEMENT}/chromedriver.exe"))) then(File.delete(target_placement)) end
    FileUtils.copy_file(CHROMEDRIVER_LOCATION, target_placement)
  end
end
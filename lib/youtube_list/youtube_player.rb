# An instance of this class knows how to reproduce music passed as argument in YouTube. Internet connection is needed.
class YouTubePlayer

  YOUTUBE_URL = 'https://www.youtube.com/'
  DATA_LOCATION = "#{File.dirname(File.dirname(File.dirname(__FILE__)))}/data"
  ADBLOCK_LOCATION = "#{DATA_LOCATION}/adblockpluschrome.crx"
  CHROMEDRIVER_LOCATION = "#{DATA_LOCATION}/chromedriver.exe"
  TARGET_CHROMEDRIVER_PLACEMENT = "#{ENV['APPDATA'].gsub('\\', '/')}/JorobusLab/YouTubeLister"
  AMOUNT_OF_PLAYABLES_TO_INSPECT = 3
  # minutes from where a playable item is recognized as an album
  KNOWN_AS_SONG_LIMIT = 20

  # @param song_list [Array]. At least there's one song in the list, thats assured.
  def initialize(song_list)
    @song_list = song_list #: Array of Song
    place_chromedriver_in_c()
    add_chromedriver_to_path()
    # we don't want undesirable logs
=begin
    # in the waitr version used this is not working, output is still going to $stdout
    logger = Selenium::WebDriver.logger
    logger.level = :fatal
    logger.output = "#{TARGET_CHROMEDRIVER_PLACEMENT}/log.log"
=end
    # set and start the browser
    profile = Selenium::WebDriver::Chrome::Profile.new()
    # activate addblock extension
    profile.add_extension(ADBLOCK_LOCATION)
    profile['extensions.disabled'] = false
    $logger.puts('Initializing driver, ignore warnings...')
    webdriver = Selenium::WebDriver.for(:chrome, profile: profile)
    $logger.puts('Cleaning browser, ignore (or manually close) adblocker pop-up...')
    @browser = Watir::Browser.start(YOUTUBE_URL, webdriver)
    # there could be more than one windows (tabs) opened, let just one on top
    if(@browser.windows.size > 1)
      @browser.windows.last.close
      @browser.windows.first.use
    end
    sleep(0.75)
  end

  # Opens Chrome instance, travel to YouTube, seek for songs, and reproduce them.
  def play_songs
    @song_list.each do |song|
      # travel to YouTube if not there yet
      if(!@browser.url.match('youtube')) then(@browser.goto(YOUTUBE_URL)) end
      # check if important elements are loaded, otherwise wait for them
      ready = false
      until(ready)
        if(@browser.text_field.visible?)
          ready = true
          sleep(0.75)
        end
      end
      # the song is formatted with a '-' dividing artist and song, format it accordly for this task. Try to get HQ song first
      string_for_searcher_hq = get_string_for_searcher(song, hq: true) #: String
      @browser.text_field.value = string_for_searcher_hq #: String
      @browser.button(:class, 'search-button').click
      # wait until important elements gets loaded
      ready = false
      until(ready)
        h3s = @browser.h3s(:class, 'yt-lockup-title').to_a
        if((h3s.size >= 3) && (h3s[2].visible?))
          ready = true
          sleep(0.75)
        end
      end
      # first three titles are really needed
      h3s = h3s.first(AMOUNT_OF_PLAYABLES_TO_INSPECT)
      # try to find a proper hq playable
      proper_playable = find_proper_playable(song, h3s) #: Fixnum or NilClass
      if(proper_playable)
        # play it
        $logger.puts("Playing: \"#{song.to_s}\".")
        h3s[proper_playable].click
      else
        # try to find just a proper playable
        string_for_searcher = get_string_for_searcher(song, hq: false) #: String
        @browser.text_field.value = string_for_searcher #: String
        @browser.button(:class, 'search-button').click
        # wait until important elements gets loaded
        ready = false
        until(ready)
          h3s = @browser.h3s(:class, 'yt-lockup-title').to_a
          if((h3s.size >= 3) && (h3s[2].visible?))
            ready = true
            sleep(0.75)
          end
        end
        # get first three titles
        h3s = h3s.first(AMOUNT_OF_PLAYABLES_TO_INSPECT)
        proper_playable = find_proper_playable(song, h3s) #: Fixnum or NilClass
        if(proper_playable)
          # play it
          $logger.puts("Playing: \"#{song.to_s}\".")
          h3s[proper_playable].click
        else
          # woops, no song found, go with the next one
          $logger.puts("Mmm... seems that there's no \"#{song.to_s}\" in YT (or I'm not very wise), skipping...")
          next
        end
      end
      # census until the song finish getting reproduced
      progress_bar = @browser.element(:class, 'ytp-play-progress')
      while(true)
        if(progress_bar.style.match(/transform: scaleX\(1\)/))
          break
        else
          sleep(0.5)
        end
      end
    end
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
          _duration = title.parent.parent.span(class: 'video-time').text rescue nil #: String
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
    if(!(File.exists?(target_placement = "#{TARGET_CHROMEDRIVER_PLACEMENT}/chromedriver.exe"))) then(FileUtils.copy_file(CHROMEDRIVER_LOCATION, target_placement)) end
  end
end
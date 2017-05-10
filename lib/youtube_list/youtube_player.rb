# An instance of this class knows how to reproduce music passed as argument in YouTube. Internet connection is needed.
class YouTubePlayer

  YOUTUBE_URL = 'https://www.youtube.com/'
  DATA_LOCATION = "#{File.dirname(File.dirname(File.dirname(__FILE__)))}/data"
  ADBLOCK_LOCATION = "#{DATA_LOCATION}/adblockpluschrome.crx"
  CHROMEDRIVER_LOCATION = "#{DATA_LOCATION}/chromedriver.exe"
  TARGET_CHROMEDRIVER_PLACEMENT = "#{ENV['APPDATA'].gsub('\\', '/')}/JorobusLab/YouTubeLister"

  # @param song_list [Array]. At least there's one song in the list, thats assured.
  def initialize(song_list)
    @song_list = song_list #: Array of Song
    place_chromedriver_in_c()
    add_chromedriver_to_path()
    # we don't want undesirable logs
    logger = Selenium::WebDriver.logger
    logger.level = :fatal
    logger.output = "#{TARGET_CHROMEDRIVER_PLACEMENT}/log.log"
    # set and start the browser
    profile = Selenium::WebDriver::Chrome::Profile.new()
    # activate addblock extension
    profile.add_extension(ADBLOCK_LOCATION)
    profile['extensions.disabled'] = false
    puts('Initializing driver, ignore warnings...')
    webdriver = Selenium::WebDriver.for(:chrome, profile: profile)
    puts('Cleaning console...')
    @browser = Watir::Browser.start(YOUTUBE_URL, webdriver)
    # there could be more than one windows (tabs) opened, let just one on top
    if(@browser.windows.size > 1)
      @browser.windows.last.close
      @browser.windows.first.use
    end
    sleep(0.75)
    system('cls')
  end

  # Opens Chrome instance, travel to YouTube, seek for songs, and reproduce them.
  def play_songs
    @song_list.each do |song|
      # travel to YouTube if not there yet
      if(!@browser.url.match('youtube')) then(@browser.goto(YOUTUBE_URL); sleep(1)) end
      # the song is formatted with a '-' dividing artist and song, format it accordly for this task. Try to get HQ song first
      string_for_searcher_hq = get_string_for_searcher(song, hq: true) #: String
      @browser.text_field.value = string_for_searcher_hq #: String
      @browser.button(:class, 'search-button').click
      # wait a while for the page to get loaded
      sleep(1)
      # inquire on the first appearance
      first_appearance = @browser.h3(:class, 'yt-lockup-title')
      # check if this is in fact the looked song
      first_appearance_text = first_appearance.text #: String
      if((first_appearance_text.match(Regexp.new(Regexp.escape(song.artist), true))) && (first_appearance_text.match(Regexp.new(Regexp.escape(song.song), true))))
        # perfect, a HQ song has been probably found, reproduce it
        puts("Playing: \"#{song.to_s}\".")
        @browser.h3(:class, 'yt-lockup-title').click
      else
        # seems that for HQ there's no song, try to find a non-HQ
        string_for_searcher = get_string_for_searcher(song, hq: false) #: String
        @browser.text_field.value = string_for_searcher #: String
        @browser.button(:class, 'search-button').click
        # wait a while for the page to get loaded
        sleep(1)
        # inquire on the first appearance
        first_appearance = @browser.h3(:class, 'yt-lockup-title')
        # check if this is in fact the looked song
        first_appearance_text = first_appearance.text #: String
        if((first_appearance_text.match(Regexp.new(Regexp.escape(song.artist), true))) && (first_appearance_text.match(Regexp.new(Regexp.escape(song.song), true))))
          # not a HQ but works, reproduce it
          puts("Playing: \"#{song.to_s}\".")
          @browser.h3(:class, 'yt-lockup-title').click
        else
          # woops, no song found, go with the next one
          puts("Mmm... seems that there's no \"#{song.to_s}\" in YT (or I'm not very wise), skipping...")
          next
        end
      end
      # census until the song finish getting reproduced
      progress_bar = @browser.element(:class, 'ytp-play-progress')
      while(true)
        if(progress_bar.style.match(/transform: scaleX\(1\)/))
          break
        else
          sleep(1)
        end
      end
    end
  end

  private

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
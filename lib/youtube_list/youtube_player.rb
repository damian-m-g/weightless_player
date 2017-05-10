# An instance of this class knows how to reproduce music passed as argument in YouTube. Internet connection is needed.
class YouTubePlayer

  YOUTUBE_URL = 'https://www.youtube.com/'

  # @param song_list [Array]. At least there's one song in the list, thats assured.
  def initialize(song_list)
    @song_list = song_list #: Array of Song
    add_chromedriver_to_path()
    # set and start the browser
    profile = Selenium::WebDriver::Chrome::Profile.new()
    # activate addblock extension
    profile.add_extension("#{File.dirname($wd)}/data/adblockpluschrome-1.12.4.1722.crx")
    profile['extensions.disabled'] = false
    webdriver = Selenium::WebDriver.for(:chrome, profile: profile)
    @browser = Watir::Browser.start(YOUTUBE_URL, webdriver)
    # there could be more than one windows (tabs) opened, let just one on top
    if(@browser.windows.size > 1)
      @browser.windows.last.close
      @browser.windows.first.use
    end
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
          puts("Sorry... seems that there's no \"#{song.to_s}\" in YouTube, skipping...")
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

  # TODO: Modify target chromedriver path...
  def add_chromedriver_to_path
    ENV['Path'] = "#{ENV['Path']};C:\\chromedriver"
  end
end
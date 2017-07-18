# Main class of the application.
class Main

  SUPPORTED_FILES = ['m3u8', 'txt']

  # @param wd [String].
  def initialize(wd)
    # a logger will be in charge of be logging information to the console
    $logger = YouTubeList::Logger.new()
    $logger.puts('Hello user, welcome.')
    $wd = wd #: String

    path = get_youtube_list_file() #: String or NilClass
    if(path)
      case(File.extname(path))
        when('.m3u8')
          @interpreter = M3U8Interpreter.new(path)
        when('.txt')
          @interpreter = RawTXTInterpreter.new(path)
      end
    else
      exit(1)
    end

    @song_list = @interpreter.get_song_list #: Array of Song
    $logger.puts("#{@song_list.size} song/s detected.")
    if(@song_list.empty?)
      $logger.puts('Exiting in 10 seconds.')
      sleep(10)
      exit(1)
    else
      @youtube_player = YouTubePlayer.new(@song_list)
      $logger.puts('Playing song/s...')
      @youtube_player.play_songs()
      $logger.puts('The whole list has been played, thanks for listening.')
      $logger.puts('The player will let YouTube reproduce related songs automatically...')
      sleep(60)
    end
  end

  private

  # @return [String or NilClass].
  def get_youtube_list_file
    Dir["#{$wd}/*.{#{SUPPORTED_FILES.join(',')}}"].first
  end
end
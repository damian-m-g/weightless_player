# Main class of the application.
class Main

  SUPPORTED_FILES = ['m3u8', 'txt']

  # @param wd [String].
  def initialize(wd)
    # derive standard and error output, so the chromedriver writes to a random place
    $original_stdout = $stdout
    $stdout = StringIO.new()
    $stderr = StringIO.new()
    $original_stdout.puts('Hello user, welcome.')
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
    $original_stdout.puts("#{@song_list.size} song/s detected.")
    if(@song_list.empty?)
      $original_stdout.puts('Exiting in 10 seconds.')
      sleep(10)
      exit(1)
    else
      @youtube_player = YouTubePlayer.new(@song_list)
      $original_stdout.puts('Playing song/s...')
      @youtube_player.play_songs()
      $original_stdout.puts('The whole list has been played, thanks for listening.')
      sleep(60)
    end
  end

  private

  # @return [String or NilClass].
  def get_youtube_list_file
    Dir["#{$wd}/*.{#{SUPPORTED_FILES.join(',')}}"].first
  end
end
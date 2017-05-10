# Main class of the application.
class Main

  SUPPORTED_FILES = ['m3u8', 'txt']

  # @param wd [String].
  def initialize(wd = File.absolute_path(File.dirname(ENV['OCRA_EXECUTABLE'])))
    puts('Hello user, welcome.')
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
    puts("#{@song_list.size} songs detected.")
    if(@song_list.empty?)
      puts('Exiting in 10 seconds.')
      sleep(10)
      exit(1)
    else
      @youtube_player = YouTubePlayer.new(@song_list)
      puts('Playing them.')
      @youtube_player.play_songs()
      puts('The whole list has been played, thanks for listening.')
      sleep(60)
    end
  end

  private

  # @return [String or NilClass].
  def get_youtube_list_file
    Dir["#{$wd}/*.{#{SUPPORTED_FILES.join(',')}}"].first
  end
end
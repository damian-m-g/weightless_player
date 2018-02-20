# Main class of the application.
class Main

  SUPPORTED_FILES = ['m3u8', 'txt']

  # @param wd [String].
  def initialize(wd)
    $wd = wd
    @youtube_player = YouTubePlayer.new()
    @gui = GUI.new(@youtube_player)
  end
end
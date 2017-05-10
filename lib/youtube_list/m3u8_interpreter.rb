# An instance of this class interprets Winamp *.m3u8 files.
class M3U8Interpreter < SongListInterpreter

  attr_reader :list_path

  # @return [Array]. Returns an array of #Song objects.
  def get_song_list
    list = []
    file_content = File.open(@list_path, 'r:utf-8:utf-8') {|f| f.read}
    file_content.scan(/#EXTINF:\d+,(.*)/).flatten.each do |song_as_string|
      m = song_as_string.match(/(.*)\s-\s(.*)/)
      list << Song.new(m[1], m[2])
    end
    list
  end
end
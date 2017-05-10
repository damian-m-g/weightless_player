# An instance of this class interprets raw *.txt files.
class RawTXTInterpreter < SongListInterpreter

  attr_reader :list_path

  # @return [Array]. Returns an array of #Song objects.
  def get_song_list
    list = []
    file_content = File.open(@list_path, 'r:utf-8:utf-8') do |f|
      f.each_line do |line|
        stripped_line = line.strip #: String
        if(stripped_line != '')
          m = stripped_line.match(/(.*)\s*-\s*(.*)/)
          if(m)
            list << Song.new(m[1], m[2])
          end
        end
      end
    end
    list
  end
end
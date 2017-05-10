# An instance of this class represents a song to look on YouTube.
class Song

  attr_reader :artist, :song

  # @param artist [String], @param song [String].
  def initialize(artist, song)
    @artist = artist
    @song = song
  end

  # @return [String].
  def to_s
    "#{@artist} - #{@song}"
  end
end
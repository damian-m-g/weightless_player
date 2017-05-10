# external libraries
require 'watir'
require 'fileutils'
require 'stringio'

# source code
require_relative '../lib/youtube_list/main'
require_relative '../lib/youtube_list/song'
require_relative '../lib/youtube_list/song_list_interpreter'
require_relative '../lib/youtube_list/m3u8_interpreter'
require_relative '../lib/youtube_list/raw_txt_interpreter'
require_relative '../lib/youtube_list/youtube_player'

if(defined?(Ocra))
  exit()
else
  begin
    system('title YouTube Lister')
    # for thesting purpose use File.absolute_path('./test') as argument of next method
    Main.new()
  rescue RuntimeError => e
    warn(e.message)
    warn(e.backtrace)
    warn('An error has arised. Please take a screen-capture and send it to the programmer.')
    sleep(60)
    exit!()
  end
end
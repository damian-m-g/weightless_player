# external libraries
require 'watir'
require 'fileutils'

# source code
require_relative '../lib/youtube_list/logger'
require_relative '../lib/youtube_list/main'
require_relative '../lib/youtube_list/song'
require_relative '../lib/youtube_list/song_list_interpreter'
require_relative '../lib/youtube_list/m3u8_interpreter'
require_relative '../lib/youtube_list/raw_txt_interpreter'
require_relative '../lib/youtube_list/youtube_player'

# ocra execution preventer
if(defined?(Ocra))
  exit()
else
  begin
    system('title Weightless Player')
    Main.new(ARGV.first || File.absolute_path(File.dirname(ENV['OCRA_EXECUTABLE'])))
  rescue StandardError, NoMemoryError, SystemStackError => e
    ## SPECIAL CASE BEGIN
    # I dont want to show errors to ppl
    exit!()
    ## SPECIAL CASE END
    warn('')
    warn("Error: #{e.class}.")
    warn("Message: #{e.message}.")
    warn("Backtrace: #{e.backtrace.inspect}.")
    warn('Please take a screen-capture and send it to the programmer.')
    sleep(60)
    exit()
  end
end
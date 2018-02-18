# external libraries
require 'selenium-webdriver'
require 'watir'
require 'fox16'; include Fox
require 'fox16/colors'

# standard libraries
require 'fileutils'
require 'win32ole'

# source code
require_relative '../lib/youtube_list/logger'
require_relative '../lib/youtube_list/main'
require_relative '../lib/youtube_list/song'
require_relative '../lib/youtube_list/song_list_interpreter'
require_relative '../lib/youtube_list/m3u8_interpreter'
require_relative '../lib/youtube_list/raw_txt_interpreter'
require_relative '../lib/youtube_list/youtube_player'
require_relative '../lib/youtube_list/autoitx3'
require_relative '../lib/youtube_list/v_fxpainter'

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
=begin
    exit!()
=end
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
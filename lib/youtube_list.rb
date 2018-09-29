# external libraries
require 'selenium-webdriver'
require 'watir'
require 'fox16'; include Fox
require 'fox16/colors'
require 'win32/mutex'
# the only purpose the next line is here is for Ocra, that can't detect it (it's used for himself or other gems) if you don't require it
require 'mini_portile2'

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
require_relative '../lib/youtube_list/v_gui'
require_relative '../lib/youtube_list/v_fxpainter'

# ocra execution preventer
if(defined?(Ocra))
  exit()
else
  begin
    begin
      mx = Win32::Mutex.new(true, 'Weightless Player', false)
      mx.wait
      system('title Weightless Player')
      Main.new(wd: ARGV.first || File.absolute_path(File.dirname(ENV['OCRA_EXECUTABLE'])), browser_hidden: (ARGV[1] == 'false' ? false : true))
    ensure
      mx.release
    end
  rescue StandardError, NoMemoryError, SystemStackError => e
    # ATTENTION: SPECIAL CASE BEGIN
    # you'll want to comment the next line if you're debugging. Currently there's no good way to show errors to people, for now is better to just exit
    exit()
    # ATTENTION: SPECIAL CASE ENDS
    warn('')
    warn("Error: #{e.class}.")
    warn("Message: #{e.message}.")
    warn("Backtrace: #{e.backtrace.inspect}.")
    warn('Please take a screen-capture and send it to the programmer.')
  end
end
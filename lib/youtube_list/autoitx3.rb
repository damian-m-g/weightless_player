# An instance of this class represents an AutoItX3 WIN32OLE server.
class AutoItX3

  HIDING_TIMEOUT = 10 # in seconds
  BROWSER_WINDOW_NAME = 'YouTube - Google Chrome'
  SW_HIDE = 0
  SW_SHOW = 5

  def initialize
    @server = WIN32OLE.new('AutoItX3.Control')
    # set matching option for window title, 2 is match substring, 3 is match exact, 1 is match from the beginning
    @server.opt('WinTitleMatchMode', 3)
  end

  # Find the browser handler, and hide it.
  def hide_browser
    # acquire window handler if needed
    if(!@window_handler)
      acquire_window_handler()
    end
    @server.WinSetState(@window_handler, '', SW_HIDE)
  end

  # Shows the browser if it's hidden. Is supposed that @window_handler was already acquired.
  def show_browser
    @server.WinSetState(@window_handler, '', SW_SHOW)
  end

  private

  # Force the acquirement of the corresponding @window_handler. Ovewrite existing if exists.
  def acquire_window_handler
    # priority is to hide it quicker as you can
    if(@server.WinWait(BROWSER_WINDOW_NAME, '', HIDING_TIMEOUT) == 1)
      # connection has been made, get handler
      pseudo_handle = @server.WinGetHandle(BROWSER_WINDOW_NAME)
      @window_handler = "[HANDLE:#{pseudo_handle}]" #: String
    else
      # connection couldn't be made
      raise(RuntimeError, "AutoItX3 can't find '#{BROWSER_WINDOW_NAME}' window.")
    end
  end
end
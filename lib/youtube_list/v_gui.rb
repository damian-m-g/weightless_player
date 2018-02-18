require 'fox16'; include Fox
require 'fox16/colors'
require_relative '../../lib/youtube_list/v_fxpainter'

class GUI

  APP_NAME = 'Weightless Player'
  VENDOR_NAME = 'JorobusLab'
  ASSETS_PLACEMENTS = "#{File.dirname(File.dirname(File.dirname(__FILE__)))}/data"
  PATH_TO_DESKTOP = "C:/Users/#{ENV['user']}/Desktop"
  DEFAULT_PL_CONTAINER = "#{PATH_TO_DESKTOP}/playlists"

  def initialize
    @app = FXApp.new(APP_NAME, VENDOR_NAME)
    create_window()
    create_app()
    @main_window.show(PLACEMENT_OWNER)
    @app.run()
  end

  private

  def create_window
    # basic stuff
    @icon = File.open("#{ASSETS_PLACEMENTS}/icon.ico", 'rb') {|f| FXICOIcon.new(@app, f.read, opts: IMAGE_ALPHAGUESS)}
    @miniIcon = File.open("#{ASSETS_PLACEMENTS}/icon.ico", 'rb') {|f| FXICOIcon.new(@app, f.read, opts: IMAGE_ALPHAGUESS)}
    # second argument is the name of the window
    @main_window = FXMainWindow.new(@app, (APP_NAME), icon: @icon, miniIcon: @miniIcon, width: 425, height: 650, opts: DECOR_TITLE|DECOR_MINIMIZE|DECOR_CLOSE|DECOR_BORDER)
    # construct the tooltip
    FXToolTip.new(@app, opts: TOOLTIP_NORMAL)
    # construct the interface
    vertical_0 = FXVerticalFrame.new(@main_window, opts: LAYOUT_FILL, padding: 15)

    # first row: the folder-to-look-for selection
    horizontal_0 = FXHorizontalFrame.new(vertical_0, opts: LAYOUT_FILL_X)
    @chosen_pl_container = DEFAULT_PL_CONTAINER
    @label_pl_container = FXLabel.new(horizontal_0, "PL container: #{@chosen_pl_container.gsub('/', '\\')}", opts: LAYOUT_FILL_X|ICON_UNDER_TEXT|JUSTIFY_LEFT|LAYOUT_CENTER_Y)
    @folder_icon = File.open("#{ASSETS_PLACEMENTS}/choose_folder.png", 'rb') {|f| FXPNGIcon.new(@app, f.read, opts: IMAGE_ALPHAGUESS)}
    button_0 = FXButton.new(horizontal_0, nil, @folder_icon)
    button_0.connect(SEL_COMMAND) do |sender, selector, data|
      # if comes as "\" version, empty string if canceled
      selected_folder = FXDirDialog.getOpenDirectory(@main_window, 'Select the folder containing PLs', ((@chosen_pl_container == DEFAULT_PL_CONTAINER) ? PATH_TO_DESKTOP.gsub('/', '\\') : @chosen_pl_container.gsub('/', '\\')))
      if(selected_folder != '')
        @label_pl_container.text = "PL container: #{selected_folder}"
        @chosen_pl_container = selected_folder.gsub('\\', '/')
        1
      else
        0
      end
    end
    packer_0 = FXPacker.new(vertical_0, padding: 0)
    horizontal_separator_0 = FXHorizontalSeparator.new(vertical_0, opts: SEPARATOR_LINE|LAYOUT_FILL_X)
    horizontal_separator_0.borderColor = FXColor::Black
    horizontal_separator_0.backColor = FXColor::Black

    # second row: the playlists list
    packer_1 = FXPacker.new(vertical_0, padding: 0, padTop: 15, padLeft: 7)
    table_0 = FXTable.new(packer_1, opts: TABLE_NO_COLSELECT|TABLE_READONLY|LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT, width: 380, height: 96)
    # table settings
    table_0.columnHeaderMode = LAYOUT_FIX_HEIGHT
    table_0.columnHeaderHeight = 23
    table_0.defRowHeight = 18
    table_0.gridColor = FXColor::Black
    table_0.rowHeaderMode = LAYOUT_FIX_WIDTH
    table_0.rowHeaderWidth = 0
    # table_0.selBackColor = FXColor::Blue
    # table_0.selTextColor = FXColor::Black
    table_0.visibleColumns = 2
    table_0.visibleRows = 4
    table_0.scrollStyle = VSCROLLER_ALWAYS|HSCROLLER_NEVER|HSCROLLING_OFF|VSCROLLING_ON|SCROLLERS_TRACK
    # fill the table
    table_0.setTableSize(4, 2)
    table_0.setColumnWidth(0, 324)
    table_0.setColumnWidth(1, 40)
    table_0.setColumnText(0, 'Name')
    table_0.setColumnText(1, 'Type')
    table_0.setItemText(0, 0, 'Type')
    table_0.setItemJustify(0, 0, FXTableItem::LEFT|FXTableItem::CENTER_Y)
    table_0.setItemText(0, 1, 'Type')
    table_0.setItemJustify(0, 1, FXTableItem::LEFT|FXTableItem::CENTER_Y)
    table_0.setItemText(1, 0, 'Type')
    table_0.setItemJustify(1, 0, FXTableItem::LEFT|FXTableItem::CENTER_Y)
    table_0.setItemText(1, 1, 'Type')
    table_0.setItemJustify(1, 1, FXTableItem::LEFT|FXTableItem::CENTER_Y)
    # functioning
    table_0.connect(SEL_SELECTED) do |sender, selector, data|
      table_0.selectRow(data.row)
      0
    end

    # third row: the playlists list
    packer_2 = FXPacker.new(vertical_0, padding: 0, padTop: 15, padLeft: 7)
    table_1 = FXTable.new(packer_2, opts: TABLE_NO_COLSELECT|TABLE_READONLY|LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT, width: 380, height: 312)
    # table settings
    table_1.columnHeaderMode = LAYOUT_FIX_HEIGHT
    table_1.columnHeaderHeight = 23
    table_1.defRowHeight = 18
    table_1.gridColor = FXColor::Black
    table_1.rowHeaderMode = LAYOUT_FIX_WIDTH
    table_1.rowHeaderWidth = 0
    # table_1.selBackColor = FXColor::Blue
    # table_1.selTextColor = FXColor::Black
    table_1.visibleColumns = 2
    table_1.visibleRows = 12
    table_1.scrollStyle = VSCROLLER_ALWAYS|HSCROLLER_NEVER|HSCROLLING_OFF|VSCROLLING_ON|SCROLLERS_TRACK
    # fill the table
    table_1.setTableSize(16, 2)
    table_1.setColumnWidth(0, 182)
    table_1.setColumnWidth(1, 182)
    table_1.setColumnText(0, 'Artist')
    table_1.setColumnText(1, 'Song')
    table_1.setItemText(0, 0, 'Type')
    table_1.setItemJustify(0, 0, FXTableItem::LEFT|FXTableItem::CENTER_Y)
    table_1.setItemText(0, 1, 'Type')
    table_1.setItemJustify(0, 1, FXTableItem::LEFT|FXTableItem::CENTER_Y)
    table_1.setItemText(1, 0, 'Type')
    table_1.setItemJustify(1, 0, FXTableItem::LEFT|FXTableItem::CENTER_Y)
    table_1.setItemText(1, 1, 'Type')
    table_1.setItemJustify(1, 1, FXTableItem::LEFT|FXTableItem::CENTER_Y)
    # functioning
    table_1.connect(SEL_SELECTED) do |sender, selector, data|
      table_1.killSelection
      # it has to select the previous selected row, if it were
      0
    end

    # paint widgets
    FXPainter.paint_background(FXColor::DodgerBlue3, vertical_0, @label_pl_container, horizontal_0, packer_0, packer_1, packer_2)
  end

  def create_app
    @app.create
    @app.disableThreads
    @app.sleepTime = 0
  end
end

GUI.new
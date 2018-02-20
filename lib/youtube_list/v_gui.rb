require 'fox16'; include Fox
require 'fox16/colors'
require_relative '../../lib/youtube_list/v_fxpainter'

class GUI

  APP_NAME = 'Weightless Player'
  VENDOR_NAME = 'JorobusLab'
  ASSETS_PLACEMENTS = "#{File.dirname(File.dirname(File.dirname(__FILE__)))}/data"
  PATH_TO_DESKTOP = "C:/Users/#{ENV['user']}/Desktop"
  DEFAULT_PL_CONTAINER = "#{PATH_TO_DESKTOP}/playlists"
  PERSISTED_DATA_PATH = "#{ENV['AppData'].gsub('\\', '/')}/JorobusLab/WeightlessPlayer/wp.db"

  # @param youtube_player [YouTubePlayer].
  def initialize(youtube_player)
    @youtube_player = youtube_player
    load_persisted_data()
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
    @main_window = FXMainWindow.new(@app, (APP_NAME), icon: @icon, miniIcon: @miniIcon, width: 425, height: 637, opts: DECOR_TITLE|DECOR_MINIMIZE|DECOR_CLOSE|DECOR_BORDER)
    # construct the tooltip
    FXToolTip.new(@app, opts: TOOLTIP_NORMAL)
    # construct the interface
    vertical_0 = FXVerticalFrame.new(@main_window, opts: LAYOUT_FILL, padding: 15)

    # first row: the folder-to-look-for selection
    horizontal_0 = FXHorizontalFrame.new(vertical_0, opts: LAYOUT_FILL_X)
    @chosen_pl_container ||= DEFAULT_PL_CONTAINER
    @label_pl_container = FXLabel.new(horizontal_0, "PL container: #{@chosen_pl_container.gsub('/', '\\')}", opts: LAYOUT_FILL_X|ICON_UNDER_TEXT|JUSTIFY_LEFT|LAYOUT_CENTER_Y)
    @folder_icon = File.open("#{ASSETS_PLACEMENTS}/choose_folder.png", 'rb') {|f| FXPNGIcon.new(@app, f.read, opts: IMAGE_ALPHAGUESS)}
    button_0 = FXButton.new(horizontal_0, nil, @folder_icon)
    button_0.tipText = 'Pick another folder...'
    button_0.connect(SEL_COMMAND) do |sender, selector, data|
      # if comes as "\" version, empty string if canceled
      selected_folder = FXDirDialog.getOpenDirectory(@main_window, 'Select the folder containing playlists', ((@chosen_pl_container == DEFAULT_PL_CONTAINER) ? PATH_TO_DESKTOP.gsub('/', '\\') : @chosen_pl_container.gsub('/', '\\')))
      if((selected_folder != '') && (selected_folder.gsub('\\', '/') != @chosen_pl_container))
        @label_pl_container.text = "PL container: #{selected_folder}"
        @chosen_pl_container = selected_folder.gsub('\\', '/')
        save_persistent_data()
        fill_pl_table(chosen_pl_container_has_changed: true)
        stop_playing()
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
    @pl_table = FXTable.new(packer_1, opts: TABLE_NO_COLSELECT|TABLE_READONLY|LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT, width: 380, height: 96)
    # table settings
    @pl_table.columnHeaderMode = LAYOUT_FIX_HEIGHT
    @pl_table.columnHeaderHeight = 23
    @pl_table.defRowHeight = 18
    @pl_table.gridColor = FXColor::Black
    @pl_table.rowHeaderMode = LAYOUT_FIX_WIDTH
    @pl_table.rowHeaderWidth = 0
    @pl_table.visibleColumns = 2
    @pl_table.visibleRows = 4
    @pl_table.scrollStyle = VSCROLLER_ALWAYS|HSCROLLER_NEVER|HSCROLLING_OFF|VSCROLLING_ON|SCROLLERS_TRACK
    # functioning
    @pl_table.connect(SEL_SELECTED) do |sender, selector, data|
      @pl_table.selectRow(data.row)
      playlist_name = @playlists.keys.[](data.row) # String
      selected_playlist = @playlists[playlist_name][:songs] #: Array of #Song objects
      # check if this playlist is alread being shown in @songs_table
      if(playlist_name != @pl_shown_in_songs_table)
        # @songs_table has to be refilled
        @pl_shown_in_songs_table = playlist_name
        stop_playing()
        fill_songs_table()
      end
      1
    end
    # check every 5 seconds for a new playlist or the update of one of them
    @app.addTimeout(5000, repeat: true) do |sender, selector, data|
      fill_pl_table()
    end

    # fill the table
    fill_pl_table()

    # third row: the playlists list
    packer_2 = FXPacker.new(vertical_0, padding: 0, padTop: 15, padLeft: 7)
    @songs_table = FXTable.new(packer_2, opts: TABLE_NO_COLSELECT|TABLE_READONLY|LAYOUT_FIX_WIDTH|LAYOUT_FIX_HEIGHT, width: 380, height: 312)
    # table settings
    @songs_table.columnHeaderMode = LAYOUT_FIX_HEIGHT
    @songs_table.columnHeaderHeight = 23
    @songs_table.defRowHeight = 18
    @songs_table.gridColor = FXColor::Black
    @songs_table.rowHeaderMode = LAYOUT_FIX_WIDTH
    @songs_table.rowHeaderWidth = 0
    @songs_table.visibleColumns = 2
    @songs_table.visibleRows = 12
    @songs_table.scrollStyle = VSCROLLER_ALWAYS|HSCROLLER_NEVER|HSCROLLING_OFF|VSCROLLING_ON|SCROLLERS_TRACK
    # functioning
    @songs_table.connect(SEL_COMMAND) do |sender, selector, data|
      @songs_table.killSelection
      # it has to select the previous selected row, if it was selected
      if(@last_selected_row_in_songs_table)
        @songs_table.selectRow(@last_selected_row_in_songs_table) rescue nil
      end
      1
    end
    # fill the table
    fill_songs_table()

    # fourth row: the buttons
    horizontal_1 = FXHorizontalFrame.new(vertical_0, opts: LAYOUT_FILL_X, padLeft: 51, hSpacing: 50, padTop: 15)
    @play_icon = File.open("#{ASSETS_PLACEMENTS}/play.bmp", 'rb') {|f| FXBMPIcon.new(@app, f.read, opts: IMAGE_ALPHAGUESS)}
    @pause_icon = File.open("#{ASSETS_PLACEMENTS}/pause.bmp", 'rb') {|f| FXBMPIcon.new(@app, f.read, opts: IMAGE_ALPHAGUESS)}
    @stop_icon = File.open("#{ASSETS_PLACEMENTS}/stop.bmp", 'rb') {|f| FXBMPIcon.new(@app, f.read, opts: IMAGE_ALPHAGUESS)}
    button_1 = FXButton.new(horizontal_1, nil, @play_icon, opts: BUTTON_NORMAL|LAYOUT_FIX_HEIGHT|LAYOUT_FIX_WIDTH, height: 64, width: 64)
    button_1.tipText = 'Play'
    button_1.connect(SEL_COMMAND) do |sender, selector, data|
      if(@player_state != :playing)
        case(@player_state)
          when(:stopped)
            # not started yet. Start playing music, only if a playlist is selected
            if(@pl_shown_in_songs_table && (!(@playlists[@pl_shown_in_songs_table][:songs].empty?)))
              # play the current pl being shown
              play_from_the_beginning()
              1
            else
              0
            end
          when(:paused)
            # not started yet. Start playing music, only if a playlist is selected
            if((@pl_shown_in_songs_table) && (!(@playlists[@pl_shown_in_songs_table][:songs].empty?)) && (@song_being_reproduced) && (@song_being_reproduced[:playlist] == @pl_shown_in_songs_table))
              # play the current pl being shown
              resume_play()
              1
            else
              stop_playing()
              # not started yet. Start playing music, only if a playlist is selected
              if(@pl_shown_in_songs_table && (!(@playlists[@pl_shown_in_songs_table][:songs].empty?)))
                # play the current pl being shown
                play_from_the_beginning()
                1
              else
                0
              end
              0
            end
          else
            # not started yet. Start playing music, only if a playlist is selected
            if(@pl_shown_in_songs_table && (!(@playlists[@pl_shown_in_songs_table][:songs].empty?)))
              # play the current pl being shown
              play_from_the_beginning()
              1
            else
              0
            end
        end
      else
        0
      end
    end
    button_2 = FXButton.new(horizontal_1, nil, @pause_icon, opts: BUTTON_NORMAL|LAYOUT_FIX_HEIGHT|LAYOUT_FIX_WIDTH, height: 64, width: 64)
    button_2.tipText = 'Pause'
    button_2.connect(SEL_COMMAND) do |sender, selector, data|
      pause_playing()
      1
    end
    button_3 = FXButton.new(horizontal_1, nil, @stop_icon, opts: BUTTON_NORMAL|LAYOUT_FIX_HEIGHT|LAYOUT_FIX_WIDTH, height: 64, width: 64)
    button_3.tipText = 'Stop'
    button_3.connect(SEL_COMMAND) do |sender, selector, data|
      stop_playing()
      1
    end

    # fifth row: the volume
    packer_3 = FXPacker.new(vertical_0, opts: LAYOUT_FILL_X, padTop: 9)
    dial = FXDial.new(packer_3, opts: DIAL_HORIZONTAL|DIAL_HAS_NOTCH|LAYOUT_FILL_X)
    dial.range = 0..100
    dial.revolutionIncrement = 205
    dial.tipText = 'Volume: 0'
    dial.value = @volume = 66
    dial.connect(SEL_CHANGED) do |sender, selector, data|
      dial.tipText = "Volume: #{data}"
      touch_volumen(data)
    end
    dial.connect(SEL_COMMAND) do |sender, selector, data|
      dial.tipText = "Volume: #{data}"
      touch_volumen(data)
    end

    # paint widgets
    FXPainter.paint_background(FXColor::DodgerBlue3, vertical_0, @label_pl_container, horizontal_0, packer_0, packer_1, packer_2, horizontal_1, packer_3)
    FXPainter.paint_buttons(24, 116, 205, button_1, button_2, button_3)
    FXPainter.paint_buttons(24, 116, 205, dial)
  end

  def create_app
    @app.create
  end

  # Fills @pl_table. It always make a clean before filling.
  def fill_pl_table(chosen_pl_container_has_changed: false)
    # read *.txt and *.m3u8 files
    files = Dir["#{@chosen_pl_container}/*.{txt,m3u8}"]
    table_needs_refill = false
    if(chosen_pl_container_has_changed)
      # clean the playlist, because we're in a different container
      @playlists = {}
      table_needs_refill = true
    elsif(!@playlists)
      @playlists = {} #: This will become kind of {#String => {:censused_touch_time => #Time, :songs => #Array of #Song}
      table_needs_refill = true
    end
    files.each do |file|
      if((!(@playlists[file])) || ((@playlists[file][:censused_touch_time]) < File.mtime(file)))
        case(File.extname(file))
          when('.txt')
            interpreter = RawTXTInterpreter.new(file)
          when('.m3u8')
            interpreter = M3U8Interpreter.new(file)
        end
        song_list = interpreter.get_song_list #: Array
        @playlists[file] = {censused_touch_time: File.mtime(file), songs: song_list}
        table_needs_refill = true
      end
    end
    # erase files that aren't there anymore
    pls_to_erase = @playlists.keys - files
    pls_to_erase.each do |pl_to_erase|
      @playlists.delete(pl_to_erase)
      table_needs_refill = true
    end
    # refill the table if needed
    if(table_needs_refill)
      # set configs of the table
      @pl_table.clearItems rescue nil
      @pl_table.setTableSize(@playlists.size, 2)
      @pl_table.setColumnWidth(0, 324)
      @pl_table.setColumnWidth(1, 40)
      @pl_table.setColumnText(0, 'Name')
      @pl_table.setColumnText(1, 'Type')
      # fill it
      @playlists.keys.each_with_index do |pl, index|
        @pl_table.setItemText(index, 0, File.basename(pl, '.*'))
        @pl_table.setItemText(index, 1, File.extname(pl).[](1..-1))
        @pl_table.setItemJustify(index, 0, FXTableItem::LEFT|FXTableItem::CENTER_Y)
        @pl_table.setItemJustify(index, 1, FXTableItem::LEFT|FXTableItem::CENTER_Y)
      end
      # see if the last pl shown in songs table is still in the pl table
      if(@playlists.keys.include?(@pl_shown_in_songs_table))
        # select it if not selected
        @pl_table.selectRow(@playlists.keys.find_index(@pl_shown_in_songs_table), true)
        # update the songs table just in case it was updated
        fill_songs_table() if @songs_table
      else
        # kill selection, just in case
        @pl_table.killSelection()
        @pl_shown_in_songs_table = nil
        fill_songs_table() if @songs_table
      end
    end
  end

  # Fills @songs_table if have to do it.
  def fill_songs_table
    # set configs of the table
    @songs_table.clearItems rescue nil
    if(@pl_shown_in_songs_table)
      songs = @playlists[@pl_shown_in_songs_table][:songs] #: Array of #Song objects
      @songs_table.setTableSize(songs.size, 2)
    else
      @songs_table.setTableSize(0, 2)
    end
    @songs_table.setColumnWidth(0, 182)
    @songs_table.setColumnWidth(1, 182)
    @songs_table.setColumnText(0, 'Artist')
    @songs_table.setColumnText(1, 'Song')
    # only if there's a pl being shown, do the next
    if(@pl_shown_in_songs_table)
      # fill it
      songs.each_with_index do |song, index|
        @songs_table.setItemText(index, 0, song.artist)
        @songs_table.setItemText(index, 1, song.song)
        @songs_table.setItemJustify(index, 0, FXTableItem::LEFT|FXTableItem::CENTER_Y)
        @songs_table.setItemJustify(index, 1, FXTableItem::LEFT|FXTableItem::CENTER_Y)
      end
      # select a row, if it's being reproduced by the player
      if(@song_being_reproduced && (@song_being_reproduced[:playlist] == @pl_shown_in_songs_table))
        # seek the song being reproduced
        artist = @song_being_reproduced[:song].artist
        song = @song_being_reproduced[:song].song
        songs.each_with_index do |_song, index|
          if((_song.song == song) && (_song.artist == artist))
            @songs_table.selectRow(@last_selected_row_in_songs_table = index)
            return
          end
        end
        # if we reach this point, the song dissapeared
        @song_being_reproduced = nil
        stop_playing()
      end
    end
  end

  # Stops playing if yet playing.
  def stop_playing
    if(@player_state == :playing || @player_state == :paused)
      if(@youtube_player.touch_play_pause_button())
        @player_state = :stopped
        @song_being_reproduced = nil
        @last_selected_row_in_songs_table = nil
        @songs_table.killSelection()
      end
    end
  end

  # Pauses playing the current song, if there's one playing.
  def pause_playing
    if(@player_state == :playing)
      if(@youtube_player.touch_play_pause_button())
        @player_state = :paused
      end
    end
  end

  # Keeps playing the song paused.
  def resume_play
    if(@player_state == :paused)
      if(@youtube_player.touch_play_pause_button())
        @player_state = :playing
      end
    end
  end

  # Play the current selected playlist from its beginning.
  def play_from_the_beginning
    if(@pl_shown_in_songs_table && (!((songs = @playlists[@pl_shown_in_songs_table][:songs]).empty?)))
      @app.addTimeout(1000) do |sender, selector, data|
        @player_state = :playing
        @song_being_reproduced = {playlist: @pl_shown_in_songs_table, song: songs.first}
        @songs_table.selectRow(@last_selected_row_in_songs_table = 0)
        @app.beginWaitCursor
          if(!(@youtube_player.play_song(songs.first, (@volume / 100.0))))
            @songs_table.killSelection
            play_next_song()
          else
            timeout = @app.addTimeout(500, repeat: true) do |sender, selector, data|
              touch_volumen()
              if(@youtube_player.do_the_song_finished_playing?)
                @app.addTimeout(250) {|sender, selector, data| @app.removeTimeout(timeout)}
                play_next_song()
              end
            end
          end
        @app.endWaitCursor
      end
    end
  end

  # Looks for the next song in the list and play it.
  def play_next_song
    if(@pl_shown_in_songs_table && @song_being_reproduced &&(@pl_shown_in_songs_table == @song_being_reproduced[:playlist]) && (!((songs = @playlists[@pl_shown_in_songs_table][:songs]).empty?)))
      # find in which index the recently song played, and play the next one
      artist = @song_being_reproduced[:song].artist
      song = @song_being_reproduced[:song].song
      index_of_next_song = nil
      songs.each_with_index do |_song, index|
        if((_song.artist == artist) && (_song.song == song))
          index_of_next_song = index + 1
          break
        end
      end
      # see if in fact there's a song in that index
      if(index_of_next_song && (song_to_play = songs[index_of_next_song]))
        @song_being_reproduced = {playlist: @pl_shown_in_songs_table, song: song_to_play}
        # update the state, just in case
        @player_state = :playing
        @songs_table.selectRow(@last_selected_row_in_songs_table = index_of_next_song)
        @app.beginWaitCursor
          if(!(@youtube_player.play_song(song_to_play, (@volume / 100.0))))
            @songs_table.killSelection
            play_next_song()
          else
            timeout = @app.addTimeout(350, repeat: true) do |sender, selector, data|
              touch_volumen()
              if(@youtube_player.do_the_song_finished_playing?)
                @app.addTimeout(250) {|sender, selector, data| @app.removeTimeout(timeout)}
                play_next_song()
              end
            end
          end
        @app.endWaitCursor
      else
        # there's no song to be played, stop
        stop_playing()
      end
    end
  end

  # @param new_value [Integer]. Changes the YT volume.
  def touch_volumen(new_value = nil)
    @youtube_player.set_player_volume((@volume = new_value || @volume) / 100.0)
  end

  # @return [TrueClass or FalseClass]. Load some relevant data for the application, from an specific place in ROM, if exists. Returns false if something went wrong.
  def load_persisted_data
    if(File.exists?(PERSISTED_DATA_PATH))
      File.open(PERSISTED_DATA_PATH, 'rb') do |f|
        # the data saved as binary data is an array as primary object
        data = Marshal.load(f)
        @chosen_pl_container = data[0]
      end
      true
    else
      false
    end
  end

  # Saves important data in ROM, to be used another day.
  def save_persistent_data
    data = [@chosen_pl_container]
    # the database folder container may not exists, create it if that is the case
    create_folders_if_doesnt_exists_for(PERSISTED_DATA_PATH)
    # open the file, create it if doesn't exists and dump the data to persist
    File.open(PERSISTED_DATA_PATH, 'wb') do |f|
      Marshal.dump(data, f)
    end
  end

  # @param path [String].
  def create_folders_if_doesnt_exists_for(path)
    if(File.extname(path) != '')
      path_split = path.split('/').[](0...-1)
    else
      path_split = path.split('/')
    end
    current_path_built = ''
    path_split.each do |folder|
      current_path_built << "#{folder}/"
      if(!(Dir.exists?(current_path_built)))
        Dir.mkdir(current_path_built)
      end
    end
  end
end

# GUI.new(nil)
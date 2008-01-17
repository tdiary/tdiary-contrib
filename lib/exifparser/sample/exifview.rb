#!/usr/bin/env ruby
#
#   exifview.rb - display EXIF information as well as EXIF image
#
#   Copyright (C) 2002 Ryuichi Tamura (r-tam@fsinet.or.jp)
#
#   $Revision: 1.3 $
#   $Date: 2002/12/17 05:16:34 $
#
#   Requirements: gtk2
#   
require 'exifparser'
require 'observer'
require 'gtk2'

module Exif

  class Parser

    def each_values
      tags.each do |tag|
        next if tag == Tag::Exif::MakerNote
        yield tag.name, tag.tagID.to_s, tag.format, tag.IFD, tag.to_s
      end
    end

  end

end

module ExifView

  class SelectedFile
    include Observable

    def initialize
      @fpath = nil
    end
    attr_reader :fpath
    
    def filename=(filename)
      @fpath = File.expand_path(filename)
      begin
        exif = ExifParser.new(@fpath)
        changed
      rescue
        changed(false)
        raise
      end
      notify_observers(@fpath, exif)
    end

  end

  DisplayImage = SelectedFile.new

  #
  # Error dialog
  #
  class ErrorDialog < ::Gtk::Dialog

    def initialize(msg)
      super()
      self.set_default_size(200, 100)
      self.set_title("ExifView: Error")
      button = Gtk::Button.new("dismiss")
      button.flags |= Gtk::Widget::CAN_DEFAULT
      button.signal_connect("clicked") do destroy end
      self.action_area.pack_start(button, 0)
      button.grab_default
      label = Gtk::Label.new(msg)
      vbox.pack_start(label)
      button.show
      label.show
    end

  end

  #
  # File selection
  #
  class FileSelectionWidget < ::Gtk::FileSelection

    def initialize
      super('File selection')
      history_pulldown
      self.signal_connect('destroy') { destroy }
      self.ok_button.signal_connect('clicked') {
        catch(:read_error) {
          begin
            DisplayImage.filename = self.filename
          rescue
            ErrorDialog.new($!.message).show
            throw :read_error
          end
          destroy
        }
      }
      self.cancel_button.signal_connect('clicked') { destroy }
    end

  end

  #
  # MenuItem: Open
  #
  class OpenMenuItemWidget < ::Gtk::MenuItem

    def initialize
      super('Open')
      @filesel = nil
      self.signal_connect('activate') { 
        @filesel = FileSelectionWidget.new
        @filesel.show 
      }
    end
    attr_reader :filesel

  end

  #
  # MenuItem: Quit
  #
  class QuitMenuItemWidget < ::Gtk::MenuItem

    def initialize
      super('Quit')
      self.signal_connect('activate') { Gtk.main_quit }
    end

  end
  
  #
  # Menu Bar 
  #
  class MenuBarWidget < ::Gtk::MenuBar

    def initialize
      super()
      @item_open =  OpenMenuItemWidget.new
      @item_quit =  QuitMenuItemWidget.new
      menu = Gtk::Menu.new
      menu.append(@item_open)
      menu.append(@item_quit)
      filemenu = Gtk::MenuItem.new("File")
      filemenu.set_submenu(menu)
      self.append(filemenu)
    end

  end

  class ImageWindow < ::Gtk::ScrolledWindow

    def initialize
      super(nil, nil)
      DisplayImage.add_observer(self)
      @filename = nil
      @image = Gtk::Image.new
      @vbox = Gtk::VBox.new(false, 0)
      self.add_with_viewport(@vbox)
      self.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)
      @vbox.pack_start(@image, false, false, 0)
    end
    attr_reader :filename
    
    def update(*args)
      @filename, = *args
      @image.set(filename)
    end

  end

  class ExifDataWindow < ::Gtk::ScrolledWindow

    def initialize
      super(nil, nil)
      DisplayImage.add_observer(self)
      @model, @treeview = setup_columns()
    end

    def setup_columns
      model = Gtk::ListStore.new(String, String, String, String, String)
      # tagname, tag_id, ifd_name, value, respectedly
      treeview = Gtk::TreeView.new(model)
      cols = []; i = 0
      [["Name", 0], ["Number", 1], ["Format", 2], 
        ["IFD", 3], ["Value", 4]].each do |e|
        treeview.insert_column(
          Gtk::TreeViewColumn.new(e[0], Gtk::CellRendererText.new, 
                                  {:text => e[1]}), e[1] )
      end
      treeview.selection.set_mode(Gtk::SELECTION_SINGLE)
      self.add_with_viewport(treeview)
      [model, treeview]
    end
    
    def update(*args)
      fpath, exif = *args
      @model.clear
      exif.each_values do |e| 
        set_row(*e)
      end
    end

    private

    def set_row(tagname, tag_id, tag_format, ifd_name, value)
      iter = @model.append
      iter.set_value(0, tagname)
      iter.set_value(1, tag_id)
      iter.set_value(2, tag_format)
      iter.set_value(3, ifd_name)
      iter.set_value(4, value)
    end

  end

  class MainWindow < ::Gtk::Window

    def initialize(*args)
      super(*args)
      DisplayImage.add_observer(self)
      # Components lower: Exif data
      @exifdata = ExifDataWindow.new

      # Components middle: Image
      @image = ImageWindow.new

      # Components upper: Menu bar
      @menubar = MenuBarWidget.new

      # VBox creation
      @vbox = Gtk::VBox.new(false, 0)
      
      # signal connection for toplevel window
      self.signal_connect('destroy') { exit }
      self.signal_connect('delete_event') { exit }
    end

    def initialize_display 
      set_appearance()
      self.show_all
    end

    def update(*args)
      filename, = *args
      self.set_title("ExifView: #{filename}")
    end

    private

    def set_appearance
      # self
      self.set_size_request(640,480)
      self.set_title("ExifView #{@image.filename}")
      self.add(@vbox)
      # menubar
      @vbox.pack_start(@menubar, false, false, 0)
      # image display
      @vbox.pack_start(@image, true, true, 0)
      # exif data display
      @vbox.pack_start(@exifdata, true, true, 0)
    end

  end

end

if $0 == __FILE__
  Gtk.init
  #
  # Main
  #
  filename = ARGV.shift
  window = ExifView::MainWindow.new(Gtk::Window::TOPLEVEL)
  ExifView::DisplayImage.filename = filename if filename
  window.initialize_display
  Gtk.main
end

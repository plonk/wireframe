# -*- coding: utf-8 -*-
require 'gtk2'
require_relative 'gtk_helper'
require_relative 'my_drawing_area'
require_relative 'parallel'
require_relative 'control_panel'

class MainWindow < Gtk::Window
  include Gtk
  include GtkHelper

  def initialize()
    super()
    build
    set_border_width(10)

    signal_connect('destroy') do
      Gtk.main_quit
    end
  end

  def build
    da1 = da2 = nil
    create(HBox, spacing: 10) do |hbox|
      create(VBox, spacing: 10) do |vbox|
        da1 = create(MyDrawingArea)
        vbox.pack_start(Frame.new("透視投影").add(da1))

        da2 = create(ParallelProjectingDrawingArea)
        vbox.pack_start(Frame.new("平行投影").add(da2))

        hbox.pack_start(vbox)
      end

      hbox.pack_start(ControlPanel.new(da1, da2))

      add hbox
    end
  end
end

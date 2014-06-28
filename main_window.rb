# -*- coding: utf-8 -*-
require 'gtk2'
require_relative 'gtk_helper'
require_relative 'my_drawing_area'

class MainWindow < Gtk::Window
  include Gtk
  include GtkHelper

  def initialize()
    super()
    # set_default_size 700,700
    build

    signal_connect('destroy') do
      Gtk.main_quit
    end
  end

  def build
    create(HBox) do |hbox|
      create(VBox) do |vbox|
        @drawing_area = create(MyDrawingArea)
        vbox.pack_start(@drawing_area)

        @drawing_area2 = create(ParallelProjectingDrawingArea)
        vbox.pack_start(@drawing_area2)

        hbox.pack_start(vbox)
      end

      cp = create_control_panel
      hbox.pack_start(cp)

      add hbox
    end
  end

  def create_control_panel
    create(Alignment, 0, 0, 0, 0) do |align|
      create(VBox) do |vbox|
        [ { label: 'Cube X-Offset',
            args: [-300, 300, 1],
            value: @drawing_area.cube.offset[0],
            proc: proc do |spin|
              v = @drawing_area.cube.offset
              @drawing_area.cube.offset = Vector[spin.value, v[1], v[2]]
              @drawing_area2.cube.offset = Vector[spin.value, v[1], v[2]]
            end },
          { label: 'Cube Y-Offset',
            args: [-300, 300, 1],
            value: @drawing_area.cube.offset[1],
            proc: proc do |spin|
              v = @drawing_area.cube.offset
              @drawing_area.cube.offset = Vector[v[0], spin.value, v[2]]
              @drawing_area2.cube.offset = Vector[v[0], spin.value, v[2]]
            end },
          { label: 'Cube Z-Offset',
            args: [-300, 300, 1],
            value: @drawing_area.cube.offset[2],
            proc: proc do |spin|
              v = @drawing_area.cube.offset
              @drawing_area.cube.offset = Vector[v[0], v[1], spin.value]
              @drawing_area2.cube.offset = Vector[v[0], v[1], spin.value]
            end },
          { label: 'X Rotate',
            args: [-180, 180, 0.5],
            value: @drawing_area.x_deg,
            proc: proc do |spin|
              @drawing_area.x_deg = spin.value
              @drawing_area2.x_deg = spin.value
            end },
          { label: 'Y Rotate',
            args: [-180, 180, 0.5],
            value: @drawing_area.y_deg,
            proc: proc do |spin|
              @drawing_area.y_deg = spin.value
              @drawing_area2.y_deg = spin.value
            end },
          { label: 'Z Rotate',
            args: [-180, 180, 0.5],
            value: @drawing_area.z_deg,
            proc: proc do |spin|
              @drawing_area.z_deg = spin.value
              @drawing_area2.z_deg = spin.value
            end },
        ].each do |item|
          vbox.pack_start Label.new item[:label]
          button = create(SpinButton, *item[:args],
                          value: item[:value])
          button.set(on_value_changed: proc { item[:proc].call(button) })
          vbox.pack_start(button)
        end
        align.add vbox
      end
    end
  end
end

include Gdk
if __FILE__ == $0
  MainWindow.new(Gdk::Pixbuf.new(ARGV[0])).show_all.run
end

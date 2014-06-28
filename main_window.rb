# -*- coding: utf-8 -*-
require 'gtk2'
require_relative 'gtk_helper'
require_relative 'my_drawing_area'
require_relative 'parallel'

class MainWindow < Gtk::Window
  include Gtk
  include GtkHelper

  def initialize()
    super()
    # set_default_size 700,700
    build
    set_border_width(10)

    signal_connect('destroy') do
      Gtk.main_quit
    end
  end

  def build
    create(HBox, spacing: 10) do |hbox|
      create(VBox) do |vbox|
        frame = Frame.new("透視投影")
        @drawing_area = create(MyDrawingArea)
        frame.add @drawing_area
        vbox.pack_start(frame)

        frame2 = Frame.new("平行投影")
        @drawing_area2 = create(ParallelProjectingDrawingArea)
        frame2.add @drawing_area2
        vbox.pack_start(frame2)

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
        ].each do |item|
          vbox.pack_start Label.new item[:label]
          button = create(SpinButton, *item[:args],
                          value: item[:value])
          button.set(on_value_changed: proc { item[:proc].call(button) })
          vbox.pack_start(button)
        end

        theta = 10.fdiv(180) * Math::PI
        [ { label: 'X Rotate',
            on_left: proc {
              @drawing_area.rotation_matrix *= Matrix.x_rotate_matrix(theta)
              @drawing_area2.rotation_matrix *= Matrix.x_rotate_matrix(theta)
            },
            on_right: proc {
              @drawing_area.rotation_matrix *= Matrix.x_rotate_matrix(-theta)
              @drawing_area2.rotation_matrix *= Matrix.x_rotate_matrix(-theta)
            }
          },
          { label: 'Y Rotate',
            on_left: proc {
              @drawing_area.rotation_matrix *= Matrix.y_rotate_matrix(theta)
              @drawing_area2.rotation_matrix *= Matrix.y_rotate_matrix(theta)
            },
            on_right: proc {
              @drawing_area.rotation_matrix *= Matrix.y_rotate_matrix(-theta)
              @drawing_area2.rotation_matrix *= Matrix.y_rotate_matrix(-theta)
            }
          },
          { label: 'Z Rotate',
            on_left: proc {
              @drawing_area.rotation_matrix *= Matrix.z_rotate_matrix(theta)
              @drawing_area2.rotation_matrix *= Matrix.z_rotate_matrix(theta)
            },
            on_right: proc {
              @drawing_area.rotation_matrix *= Matrix.z_rotate_matrix(-theta)
              @drawing_area2.rotation_matrix *= Matrix.z_rotate_matrix(-theta)
            }
          },
        ].each do |item|
          vbox.pack_start(Label.new(item[:label]))
          create(HBox) do |hbox|
            hbox.pack_start(create(Button, '←', on_clicked: item[:on_left]))
            hbox.pack_start(create(Button, '→', on_clicked: item[:on_right]))
            vbox.pack_start(hbox)
          end
        end

        axis_check_button = create(CheckButton, 'Show Axes',
                                   active: @drawing_area.show_axes?)
        axis_check_button.set(on_toggled: proc {
                                @drawing_area.show_axes = !@drawing_area.show_axes?
                                @drawing_area2.show_axes = !@drawing_area2.show_axes?
                              })
        vbox.pack_start(axis_check_button)
        wire_check_button = create(CheckButton, 'Wireframe',
                                   active: @drawing_area.wireframe?)
        wire_check_button.set(on_toggled: proc {
                                @drawing_area.wireframe = !@drawing_area.wireframe?
                                @drawing_area2.wireframe = !@drawing_area2.wireframe?
                              })

        vbox.pack_start(wire_check_button)
        align.add vbox
      end
    end
  end
end

include Gdk
if __FILE__ == $0
  MainWindow.new(Gdk::Pixbuf.new(ARGV[0])).show_all.run
end

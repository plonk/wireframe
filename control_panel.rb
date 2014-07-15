# -*- coding: utf-8 -*-
require 'gtk2'
require 'matrix'
require_relative 'slider'

class ControlPanel < Gtk::Alignment
  include Gtk
  include GtkHelper

  def initialize(drawing_area1, drawing_area2)
    super(0,0,0,0)
    @das = [drawing_area1, drawing_area2]
    @slider = {}
    build

    theta = 10.fdiv(180) * Math::PI
    Gtk.timeout_add(17) do
      [:x, :y, :z].each do |letter|
        unless @slider[letter].value == 0
          modify_rotation Matrix.send("#{letter}_rotate", theta * @slider[letter].value)
        end
      end
      true
    end
  end

  def primary
    @das.first
  end

  def modify_cube_offset(index, value)
    v = @das.first.cube.offset
    @das.each do |da|
      ary = [*da.cube.offset]
      ary[index] = value
      da.cube.offset = Vector[*ary]
    end
  end

  def modify_rotation(matrix)
    @das.each do |da|
      da.rotation *= matrix
    end
  end

  def toggle(name)
    @das.each do |da|
      da.send(name.to_s + "=", !da.send(name.to_s + "?"))
    end
  end

  def build
    create(VBox) do |vbox|
      %w(x y z).each_with_index do |letter, i|
        vbox.pack_start Label.new "Cube #{letter.upcase}-Offset"
        button = create(SpinButton, -300, 300, 1,
                        value: primary.cube.offset[i],
                        on_value_changed: proc { modify_cube_offset(i, button.value) })
        vbox.pack_start(button)
      end

      %w(x y z).each do |letter|
        vbox.pack_start(Label.new("#{letter.upcase} Rotate"))
        @slider[letter.to_sym] = slider = create(Slider)
        vbox.pack_start(slider, false)
      end

      vbox.pack_start(create_check_button("Show Axes", :show_axes))
      vbox.pack_start(create_check_button("Wireframe", :wireframe))

      add vbox
    end
  end

  def create_check_button label, property
    create(CheckButton, label,
           active: primary.send("#{property}?"),
           on_toggled: proc do
             toggle(property)
           end)
  end
end

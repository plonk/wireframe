# -*- coding: undecided -*-
require 'matrix'

class Cube < GLib::Object
  attr_reader :offset

  type_register
  signal_new('changed',
             GLib::Signal::ACTION,
             nil,			# accumulator
             GLib::Type['void'])	# return type

  def initialize
    super()
    self.offset = Vector[150,0,0]
  end

  def offset=(new_offset)
    @offset = new_offset
    @sides = recalc_sides
    signal_emit('changed')
  end

  def recalc_sides
    [[0, 0, 0], [1, 0, 0],
     [1, 0, 0], [1, 0, 1],
     [1, 0, 1], [0, 0, 1],
     [0, 0, 1], [0, 0, 0],

     # 底面のバッテン
     # [0, 0, 0], [1, 0, 1],
     # [1, 0, 0], [0, 0, 1],

     [0, 1, 0], [1, 1, 0],
     [1, 1, 0], [1, 1, 1],
     [1, 1, 1], [0, 1, 1],
     [0, 1, 1], [0, 1, 0],

     [0, 0, 0], [0, 1, 0],
     [1, 0, 0], [1, 1, 0],
     [1, 0, 1], [1, 1, 1],
     [0, 0, 1], [0, 1, 1],].each_slice(2).map do |st, ed|
      [Vector[*st] * 100 + @offset, Vector[*ed] * 100 + @offset]
    end
  end

  def each_line
    @sides.each do |line|
      yield(line)
    end
  end
end

class MyDrawingArea < Gtk::DrawingArea
  attr_reader :cube, :x_deg, :y_deg, :z_deg

  type_register
  signal_new('changed',
             GLib::Signal::ACTION,
             nil,			# accumulator
             GLib::Type['void'])	# return type

  WIDTH = 700
  HEIGHT = 350

  def initialize()
    super()

    set_size_request WIDTH, HEIGHT

    signal_connect('expose-event', &method(:on_expose))
    @cube = Cube.new
    @cube.signal_connect('changed') do
      invalidate
    end

    @x_deg = 29.5
    @y_deg = -29.5
    @z_deg = 0.0

    signal_connect('changed') do
      invalidate
    end
  end

  def x_deg=(value)
    @x_deg = value
    signal_emit('changed')
  end

  def y_deg=(value)
    @y_deg = value
    signal_emit('changed')
  end

  def z_deg=(value)
    @z_deg = value
    signal_emit('changed')
  end

  def to_rad(deg)
    deg / 180 * Math::PI
  end

  def on_expose(_this, _e)
    draw(window.create_cairo_context)
    true
  end

  ORIGIN = Vector[0,0,0]
  AXIS_LENGTH = 150
  X_AXIS = Vector[AXIS_LENGTH,0,0]
  Y_AXIS = Vector[0,AXIS_LENGTH,0]
  Z_AXIS = Vector[0,0,AXIS_LENGTH]

  RED = [0.5,0,0]
  GREEN = [0,0.5,0]
  BLUE = [0,0,0.5]


  def draw_axes cr
    cr.save do
      [X_AXIS, Y_AXIS, Z_AXIS].zip([?X,?Y,?Z]).each do |tip, letter|
        cr.set_source_color [0.1,0.1,0.1]
        cr.move_to(*project2(ORIGIN))
        cr.line_to(*project2(tip))
        cr.stroke

        cr.set_source_color [0.3,0.5,0.5]
        cr.set_font_size(20)
        cr.move_to(*project2(tip) + Vector[20, 20])
        cr.show_text(letter)
      end
    end
  end

  def draw_cube(cr)
    cr.save do
      @cube.each_line do |st, ed|
        cr.set_source_color(BLUE)
        cr.move_to(*project2(st))
        cr.line_to(*project2(ed))
        cr.stroke
      end
    end
  end

  def draw cr
    cr.scale(1, 1)
    cr.set_line_width(1)

    draw_axes(cr)
    draw_cube(cr)

    cr.destroy
  end

  include Math

  def project2(vector)
    # # x_deg = 180 / 180 * Math::PI
    # y_deg = 0
    rotated = vector.z_rotate(to_rad(@z_deg)).y_rotate(to_rad(@y_deg)).x_rotate(to_rad(@x_deg))
    _project(rotated) + Vector[WIDTH/2, HEIGHT/2]
  end

  # 3D -> 2D
  def _project(vector)
    # result = Matrix[[1,0,0],[0,1,0]] * vector
    # result *= ((vector[2] - 2000) / 2000)
    # result = Matrix[[1,0,0],[0,1,0]] * vector
    # t = vector[2] * 0.5 / Math.sqrt(2)
    # Vector[result[0] - t, result[1] + t]

    # Matrix[[1,0,0],[0,1,0]] * vector

    x, y, z = vector[0], vector[1], vector[2]

    Vector[x / (800 - z) * 500 * 1.3, y / (800 - z) * 500 * 1.3]
  end

  def invalidate
    window.invalidate(window.clip_region, true)
    window.process_updates(true)
  end
end

class Vector
  include Math

  def x_rotate(theta)
    Matrix[[1,          0,           0],
           [0, cos(theta), -sin(theta)],
           [0, sin(theta),  cos(theta)]] * self
  end

  def y_rotate(theta)
    Matrix[[cos(theta),  0, sin(theta)],
           [0,           1,          0],
           [-sin(theta), 0, cos(theta)]] * self
  end

  def z_rotate(theta)
    Matrix[[cos(theta), -sin(theta),  0],
           [sin(theta),  cos(theta),  0],
           [0,                    0,  1]] * self
  end
end

class ParallelProjectingDrawingArea < MyDrawingArea
  def initialize
    super
  end

  def _project(vector)
    Matrix[[1,0,0],[0,1,0]] * vector
  end
end

# -*- coding: utf-8 -*-
require 'matrix'
require_relative 'extensions'
require_relative 'quadrangle'
require_relative 'cube'
require_relative 'gtk_helper'

class MyDrawingArea < Gtk::DrawingArea
  attr_reader :cube
  attr_reader :rotation_matrix

  type_register
  stock_signal_new('changed')

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

    @tetrahedron = Tetrahedron.new
    @tetrahedron.signal_connect('changed') do
      invalidate
    end

    @wireframe = true
    @show_axes = true

    @rotation_matrix = Matrix[[1,0,0],[0,1,0],[0,0,1]]

    signal_connect('changed') do
      invalidate
    end
  end

  def wireframe?
    @wireframe
  end

  def wireframe=(bool)
    @wireframe = bool
    signal_emit('changed')
  end

  def show_axes?
    @show_axes
  end

  def show_axes=(bool)
    @show_axes = bool
    signal_emit('changed')
  end

  def rotation_matrix=(matrix)
    @rotation_matrix = matrix
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
        cr.move_to(*project(ORIGIN))
        cr.line_to(*project(tip))
        cr.stroke

        cr.set_source_color [0.3,0.5,0.5]
        cr.set_font_size(20)
        cr.move_to(*project(tip) + Vector[20, 20])
        cr.show_text(letter)
      end
    end
  end

  VIEW_POINT = Vector[0, 0, -800]

  def draw_tetrahedron(cr)
    cr.save do
      @tetrahedron.each_side do |side|
        triangle = Triangle.new(*side.vertices.map { |v| perspective rotate v })
        draw_surface(cr, triangle)
      end
    end
  end

  def draw_cube(cr)
    cr.save do
      @cube.each_side do |side|
        quad = Quadrangle.new(*side.vertices.map { |v| perspective rotate v })

        draw_surface(cr, quad)
      end
    end
  end

  def draw_surface cr, quad
    if wireframe?
      draw_surface_wireframe(cr, quad)
    else
      draw_surface_fill(cr, quad)
    end
  end

  def draw_surface_wireframe cr, quad
    if quad.normal[2] < 0
      cr.set_line_width(1)
      cr.set_source_color(RED)
      cr.set_dash([2, 5])
    else
      cr.set_line_width(3)
      cr.set_source_color(BLUE)
      cr.set_dash([])
    end

    quad.each_line do |st, ed|
      cr.move_to(*to_2d(st))
      cr.line_to(*to_2d(ed))
      cr.stroke
    end
  end

  def draw_surface_fill cr, quad
    if quad.normal[2] < 0
    else
      cr.set_source_color([0.8, 0.3, 0.3, 0.8])
      quad.vertices.each_with_index do |vertex, i|
        if i==0
          cr.move_to(*to_2d(vertex))
        else
          cr.line_to(*to_2d(vertex))
        end
      end
      cr.line_to(*to_2d(quad.vertices[0]))
      cr.fill

      cr.set_source_color([0.1, 0.1, 0.1])
      quad.vertices.each_with_index do |vertex, i|
        if i==0
          cr.move_to(*to_2d(vertex))
        else
          cr.line_to(*to_2d(vertex))
        end
      end
      cr.line_to(*to_2d(quad.vertices[0]))
      cr.stroke
    end
  end

  def draw cr
    cr.scale(1, 1)
    cr.set_line_width(1)

    draw_axes(cr) if show_axes?
    draw_cube(cr)
    draw_tetrahedron(cr)

    cr.destroy
  end

  include Math

  def rotate(vector)
    @rotation_matrix * vector
  end

  def perspective(vector)
    x, y, z = vector[0], vector[1], vector[2]

    Vector[x.fdiv(800 - z) * 500 * 1.3, y.fdiv(800 - z) * 500 * 1.3, z] 
  end
  # 3D -> 2D

  def to_2d vector
    Vector[vector[0],vector[1]] + Vector[WIDTH/2, HEIGHT/2]
  end

  def project vector
    to_2d perspective rotate vector
  end

  def invalidate
    window.invalidate(window.clip_region, true)
    window.process_updates(true)
  end
end

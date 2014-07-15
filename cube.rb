# -*- coding: utf-8 -*-
require 'gtk2'
require 'matrix'
require_relative 'gtk_helper'

class Polyhedron < GLib::Object
  include GtkHelper

  type_register
  stock_signal_new('changed')

  attr_reader :offset

  def initialize()
    super()
    self.offset = Vector[0,0,0]
  end

  def offset=(new_offset)
    @offset = new_offset
    @sides = recalc_sides
    signal_emit('changed')
  end

  def each_side
    @sides.each do |side|
      yield(side)
    end
  end

  def recalc_sides
    fail 'unimplmented error'
  end
end

class Tetrahedron < Polyhedron
  include Math

  def initialize
    super()
  end

  def recalc_sides
=begin
       /\
      /  \
     /    \
    /~~~~~~\
   / \    / \
  /   \  /   \
 /     \/     \
+~~~~~~~~~~~~~~+
=end
    oku = [0.5,0,-sin(PI/3)]
    sita = [0.5,sin(PI/3),-sin(PI/3)/2]
    [
     # 天面
     [[0,0,0],[1,0,0],oku],
     # 正面
     [[1,0,0],[0,0,0],sita],
     # 側面1
     [[1,0,0],sita,oku],
     # 側面2
     [[0,0,0],oku,sita]
    ].map do |vertices|
      Triangle.new(*vertices.map { |ary| Vector[*ary.map { |n| n*100.0 }] + @offset })
    end
  end
end

class Cube < Polyhedron
  def initialize
    super()
  end

  def recalc_sides
    [
     # 底面
     [[0, 0, 1], [1, 0, 1], [1, 0, 0], [0, 0, 0]],
     # 天面
     [[0,1,0],[1,1,0],[1,1,1],[0,1,1]],
     # 前面
     [[0,0,0],[0,1,0],[1,1,0],[1,0,0]].reverse,
     # 右側面
     [[1,1,0],[1,0,0],[1,0,1],[1,1,1]],
     # 左側面
     [[0,1,0],[0,1,1],[0,0,1],[0,0,0]],
     # 背面
     [[1,1,1],[1,0,1],[0,0,1],[0,1,1]]
    ].map do |vertices|
      Quadrangle.new(*vertices.map { |ary| Vector[*ary.map { |n| n*100.0 }] + @offset })
    end
  end
end


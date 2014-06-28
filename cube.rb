# -*- coding: utf-8 -*-
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
    self.offset = Vector[0,0,0]
  end

  def offset=(new_offset)
    @offset = new_offset
    @sides = recalc_sides
    signal_emit('changed')
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

  def each_side
    @sides.each do |side|
      yield(side)
    end
  end
end


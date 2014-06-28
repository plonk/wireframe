require 'matrix'

class Quadrangle
  attr_reader :vertices

  def initialize(*vertices)
    fail ArgumentError, vertices.inspect  unless vertices.size == 4
    @v = vertices.map { |triples| make_vector(triples) }
  end

  def make_vector item
    if item.is_a? Vector
      item
    else
      Vector[*item]
    end
  end

  def vertices
    @v
  end

  def normal
    (@v[1] - @v[0]).cross_product(@v[2] - @v[1]).normalize
  end

  def each_vertex
    @v.each do |v|
      yield(v)
    end
    self
  end

  def each_line
    @v.cycle.each_cons(2).take(4).each do |st, ed|
      yield(st, ed)
    end
    self
  end
end

class Triangle
  attr_reader :vertices

  def initialize(*vertices)
    fail ArgumentError, vertices.inspect  unless vertices.size == 3
    @v = vertices.map { |triples| make_vector(triples) }
  end

  def make_vector item
    if item.is_a? Vector
      item
    else
      Vector[*item]
    end
  end

  def vertices
    @v
  end

  def normal
    (@v[1] - @v[0]).cross_product(@v[2] - @v[1]).normalize
  end

  def each_vertex
    @v.each do |v|
      yield(v)
    end
    self
  end

  def each_line
    @v.cycle.each_cons(2).take(3).each do |st, ed|
      yield(st, ed)
    end
    self
  end
end

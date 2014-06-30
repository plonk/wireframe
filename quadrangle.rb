require 'matrix'

class Polygon
  def initialize(*vertices)
    @v = vertices.map(&method(:make_vector))
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
    @v.cycle.each_cons(2).take(vertices.size).each do |st, ed|
      yield(st, ed)
    end
    self
  end

  def fmap(&block)
    fail 'block missing' unless block
    self.class.new(*vertices.map(&block))
  end

  private

  def make_vector item
    item.is_a?(Vector) ? item : Vector[*item]
  end

  class << self
    alias [] new

    def has_vertices(number)
      define_method :num_vertices do
        number
      end
    end

    def with_vertices(number_vertices)
      Class.new(Polygon) do
        has_vertices number_vertices

        def initialize(*vertices)
          unless vertices.size == num_vertices
            fail ArgumentError, "vertex number mismatch #{vertices.inspect}"
          end
          super(*vertices)
        end
      end
    end
  end
end

Triangle = Polygon.with_vertices(3)
Quadrangle = Polygon.with_vertices(4)

# t = Triangle[[0,-1,0],[-1,0,0],[1,0,0]]
# p t.normal # => Vector[0.0, 0.0, 1.0]
# p t.fmap { |v| v * 100 }

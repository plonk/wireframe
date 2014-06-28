require_relative 'my_drawing_area'

class ParallelProjectingDrawingArea < MyDrawingArea
  def initialize
    super
  end

  def perspective vector
    vector
  end
end

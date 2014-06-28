class PenTool
  def initialize picture_view
    @picture_view = picture_view
  end

  def handle_button_press e
    if e.button == 1
      @current_point = @start_point = [e.x, e.y]
    end
  end

  def handle_motion_notify e
    if e.state & Gdk::Window::BUTTON1_MASK != 0
      @current_point = [e.x, e.y]
      @picture_view.picture.modify do |cr|
        draw(cr)
      end
      @start_point = @current_point
    end
  end

  def handle_button_release e
    # @picture_view.picture.modify do |cr|
    #   draw(cr)
    # end
    @start_point = nil
  end

  def draw cr
    return unless @start_point

    cr.save do
      cr.set_source_color @picture_view.color.to_cairo
      cr.set_line_width @picture_view.line_width
      cr.set_line_cap(Cairo::LINE_CAP_ROUND)
      right, bottom = @current_point
      cr.move_to(*@start_point)
      cr.line_to(*@current_point)
      cr.stroke
    end
  end
end

class RectTool
  def initialize picture_view
    @picture_view = picture_view
  end

  def handle_button_press e
    if e.button == 1
      @current_point = @start_point = [e.x, e.y]
    end
  end

  def handle_motion_notify e
    if e.state & Gdk::Window::BUTTON1_MASK != 0
      @current_point = [e.x, e.y]
    end
  end

  def handle_button_release e
    @picture_view.picture.modify do |cr|
      draw(cr)
    end
    @start_point = nil
  end

  def draw cr
    return unless @start_point

    cr.save do
      cr.set_source_color @picture_view.color.to_cairo
      cr.set_line_width @picture_view.line_width
      right, bottom = @current_point
      cr.rectangle(*@start_point, right - @start_point[0], bottom - @start_point[1])
      cr.stroke
    end
  end
end

class CircleTool
  def initialize picture_view
    @picture_view = picture_view
  end

  def handle_button_press e
    if e.button == 1
      @current_point = @start_point = [e.x, e.y]
    end
  end

  def handle_motion_notify e
    if e.state & Gdk::Window::BUTTON1_MASK != 0
      @current_point = [e.x, e.y]
    end
  end

  def handle_button_release e
    @picture_view.picture.modify do |cr|
      draw(cr)
    end
    @start_point = nil
  end

  def draw cr
    return unless @start_point

    cr.save do
      cr.set_source_color @picture_view.color.to_cairo
      cr.set_line_width @picture_view.line_width
      x, y = @start_point
      xx, yy = @current_point
      radius = Math.sqrt((xx - x).abs**2 + (yy - y).abs**2)
      cr.circle(x, y, radius)
      cr.stroke
    end
  end
end

class LineTool
  def initialize picture_view
    @picture_view = picture_view
  end

  def handle_button_press e
    if e.button == 1
      @current_point = @start_point = [e.x, e.y]
    end
  end

  def handle_motion_notify e
    p :motion
    #if e.state & Gdk::Window::BUTTON1_MASK != 0
      @current_point = [e.x, e.y]
  #end
  end

  def handle_button_release e
    @picture_view.picture.modify do |cr|
      draw(cr)
    end
    @start_point = nil
  end

  def draw cr
    if @start_point
      cr.save do
        cr.set_source_color(@picture_view.color.to_cairo)
        cr.set_line_width @picture_view.line_width
        cr.set_line_cap(Cairo::LINE_CAP_ROUND)
        cr.move_to(*@start_point)
        cr.line_to(*@current_point)
        cr.stroke
      end
    else
      cr.save do
        cr.set_source_color(@picture_view.color.to_cairo)
        cr.set_line_width @picture_view.line_width
        cr.set_line_cap(Cairo::LINE_CAP_ROUND)
        cr.move_to(*@current_point)
        cr.line_to(*@current_point)
        cr.stroke
      end
    end
  end
end


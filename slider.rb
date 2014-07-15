# -*- coding: utf-8 -*-
# Self-centering slider for direction input
require_relative 'gtk_helper'

class Slider < Gtk::DrawingArea
  include GtkHelper
  include Gtk
  include Cairo

  type_register

  stock_signal_new('changed')

  attr_reader :value

  def initialize
    super()

    set_size_request(180, 40)

    @value = 0.0

    signal_connect('expose-event') do |w, event|
      draw
      true
    end

    signal_connect('configure-event') do |_, e|
      true
    end

    set_event_mask

    signal_connect('button-press-event', &method(:on_button_press))
    signal_connect('motion-notify-event', &method(:on_motion_notify))
    signal_connect('button-release-event', &method(:on_button_release))

    signal_connect('realize') do
      window.cursor = Gdk::Cursor.new(Gdk::Cursor::Type::HAND1)
    end
  end

  def on_button_press(_this, e)
    case e.button
    when 1
      self.value = coords_to_value(e.x, e.y)
      @control_state = :dragging
      true
    else
      false
    end
  end

  def on_motion_notify(_this, e)
    return false unless  (e.state & Gdk::Window::BUTTON1_MASK) != 0
    self.value = coords_to_value(e.x, e.y)
    true
  end

  def on_button_release(_this, e)
    return false unless e.button == 1
    self.value = 0.0
    true
  end

  def coords_to_value(x, y)
    result = (x - knob_width / 2).fdiv(slit_length) * 2 - 1.0
    [[-1.0, result].max, 1.0].min
  end

  def set_event_mask
    self.events |= Gdk::Event::BUTTON_PRESS_MASK
    self.events |= Gdk::Event::BUTTON_RELEASE_MASK
    self.events |= Gdk::Event::POINTER_MOTION_MASK
  end

  def invalidate
    return if window.nil?

    window.invalidate(window.clip_region, true)
    window.process_updates(true)
  end

  def value=(new_value)
    @value = new_value
    invalidate
    signal_emit('changed')
  end

  def draw
    cr = window.create_cairo_context
    cr.scale(1, 1) # dot by dot

    draw_bg(cr)
    draw_markings(cr)
    draw_knob(cr)
  end

  def draw_bg(cr)
    cr.save
  ensure
    cr.restore
  end

  # 溝
  def draw_markings(cr)
    cr.save

    # 0 marking
    cr.set_source_color [0.1, 0.1, 0.1]
    cr.set_line_width(1)
    cr.move_to(allocation.width / 2, allocation.height / 2 - knob_height / 2)
    cr.rel_line_to(0, knob_height)
    cr.stroke

    cr.antialias = :none
    cr.set_font_size(7)
    extents = cr.text_extents('0')
    cr.move_to(allocation.width / 2 - extents.width / 2,
               allocation.height / 2 - knob_height / 2 - 2)
    cr.show_text('0')

    # slit
    cr.antialias = :best
    cr.set_source_color [0.0, 0.0, 0.0]
    cr.set_line_width(5)
    cr.set_line_cap(LINE_CAP_ROUND)
    cr.move_to(knob_width / 2, allocation.height/2)
    cr.rel_line_to(allocation.width - knob_width, 0)
    cr.stroke

  ensure
    cr.restore
  end

  def draw_knob(cr)
    cr.save

    cr.set_source_color [0.2, 0.2, 0.2]
    cr.rounded_rectangle(hposition - knob_width/2,
                         vposition - knob_height/2,
                         knob_width,
                         knob_height,
                         5, 5)
    cr.fill

    # knob center line
    cr.set_source_color [1, 1, 1]
    cr.move_to(hposition, vposition - knob_height/2 + 3)
    cr.line_to(hposition, vposition + knob_height/2 - 3)
    cr.stroke
  ensure
    cr.restore
  end

  def hposition
    knob_width / 2 + slit_length * (value / 2 + 0.5)
  end

  def slit_length
    allocation.width - knob_width
  end

  def vposition
    vcenter
  end

  def knob_width
    40
  end

  def knob_height
    20
  end

  def hcenter
    allocation.width/2
  end

  def vcenter
    allocation.height/2
  end
end

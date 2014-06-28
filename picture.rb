class Picture < GLib::Object
  include Gtk
  include Gdk
  include GtkHelper

  type_register
  signal_new('changed',
             GLib::Signal::ACTION,
             nil,			# accumulator
             GLib::Type['void'])	# return type

  def self.open(filename)
    self.new Pixbuf.new filename
  end

  def self.blank_slate(width, height)
    self.new Pixbuf.blank_slate(width, height)
  end

  attr_reader :image_surface

  def initialize(pixbuf)
    super()
    @image_surface = Cairo::ImageSurface.new(pixbuf.width, pixbuf.height)
    cr = Cairo::Context.new(image_surface)
    cr.set_source_pixbuf(pixbuf)
    cr.paint
    cr.destroy
  end

  def save(filename)
    buf = Gdk::Pixmap.new(nil, @image_surface.width, @image_surface.height, 24)
    cr = buf.create_cairo_context
    cr.set_source(@image_surface)
    cr.paint
    Pixbuf.from_drawable(nil, # cmap
                         buf,
                         0, 0,
                         @image_surface.width, @image_surface.height,
                         nil, # dest
                         0,
                         0).save(filename, 'png')
  end

  def modify
    cr = Cairo::Context.new(@image_surface)
    yield(cr)
    cr.destroy
    # signal emit?
  end
end


require_relative 'main_window'

class Program
  DEFAULT_WIDTH = 640
  DEFAULT_HEIGHT = 480

  def self.main
    MainWindow.new.show_all
    Gtk.main
  end
end

Program.main

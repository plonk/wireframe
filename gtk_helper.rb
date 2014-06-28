# -*- coding: utf-8 -*-
require 'gtk2'

module GtkHelper
  def create(klass, *args, &block)
    if args.last.is_a? Hash
      options = args.pop
    else
      options = {}
    end
    widget = klass.new(*args)

    widget.__set__(options)

    block.call(widget) if block

    widget
  end
end

# 開いてモンキーパッチ
class GLib::Object
  def set(options)
    options.keys.each do |name|
      if name =~ /^on_/
        # オプション引数の処理
        signal_connect(name.to_s.sub(/\Aon_/, ''), &options[name])
      else
        value = options[name]
        send(name.to_s + '=', value)
      end
    end
    self
  end

  alias_method :__set__, :set
end


class Gdk::Color
  MAX_VALUE = (1 << 16) - 1

  def self.from_f(*values)
    unless self.validate_floats values
      raise ArgumentError, "argument format error: #{values.inspect}"
    end
    self.new *values.map { |x| MAX_VALUE * x }
  end

  private

  def self.validate_floats values
    values.size == 3 and values.all? { |v| v.is_a? Numeric }
  end
end

class GLib::Instantiatable
  def self.stock_signal_new(name)
    case name
    when 'changed'
      signal_new('changed', GLib::Signal::ACTION, nil, nil)
    else
      raise ArgumentError, "unknown stock signal #{name.inspect}"
    end
  end
end

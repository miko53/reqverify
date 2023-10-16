# frozen_string_literal: true

# Log class to filtrate some message
# according to required level
class Log
  LOG_LEVEL_NONE = 0
  LOG_LEVEL_INFO = 1
  LOG_LEVEL_DBG = 2

  def self.initialize
    @@verbose_level = LOG_LEVEL_NONE # rubocop:disable Style/ClassVars
    @@colorize_msg = false
  end

  def self.error(msg)
    colorize(:red)
    puts "error  : #{msg}"
    uncolorize
  end

  def self.warning(msg)
    colorize(:magenta)
    puts "warning: #{msg}"
    uncolorize
  end

  def self.display(msg, color = :default)
    colorize(color) unless color == :default
    puts msg
    uncolorize unless color == :default
  end

  def self.info(msg)
    colorize(:green)
    puts "info   : #{msg}" if @@verbose_level >= LOG_LEVEL_INFO
    uncolorize
  end

  def self.debug(msg)
    puts "dbg    : #{msg}" if @@verbose_level >= LOG_LEVEL_DBG
  end

  def self.debug_pp(obj)
    pp obj if @@verbose_level >= LOG_LEVEL_DBG
  end

  def self.verbose_level=(lvl)
    @@verbose_level = lvl # rubocop:disable Style/ClassVars
  end

  def self.verbose_level
    @@verbose_level
  end

  def self.colorize_msg=(lvl)
    @@colorize_msg = lvl # rubocop:disable Style/ClassVars
  end

  def self.colorize_msg
    @@colorize_msg
  end

  def self.colorize(color)
    return if @@colorize_msg == false

    case color
    when :red
      print "\e[31m"
    when :green
      print "\e[32m"
    when :magenta
      print "\e[35m"
    end
  end

  def self.uncolorize
    return if @@colorize_msg == false

    print "\e[0m"
  end

  private_class_method :colorize, :uncolorize
end

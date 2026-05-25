# frozen_string_literal: true

require "logger"

# Jekyll 3.x ships a Logger subclass that does not call Logger#initialize.
# Ruby 3.3 Logger#level expects @level_override to exist, so initialize it
# lazily for legacy Logger subclasses used by github-pages 215 / Jekyll 3.9.
class Logger
  unless method_defined?(:acad_homepage_original_level)
    alias_method :acad_homepage_original_level, :level

    def level
      @level_override ||= {}
      acad_homepage_original_level
    end
  end
end

class Object
  def tainted?
    false
  end unless method_defined?(:tainted?)

  def taint
    self
  end unless method_defined?(:taint)

  def untaint
    self
  end unless method_defined?(:untaint)
end

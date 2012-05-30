require 'singleton'

module Norm
  class Requirements
    include Singleton

    def self.add(regex, &block)
      instance.add(regex, &block)
    end

    def self.call(string)
      instance.call(string)
    end

    attr_reader :items

    def initialize
      @items = {}
    end

    def add(string)
      puts "\n\n#{ GREEN }#{string}\n"
      puts '=' * string.length + "#{ NORMAL }"
    end
  end
end
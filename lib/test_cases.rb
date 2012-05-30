require 'singleton'

module Norm
  class TestCases
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

    def add(regex, &block)
      items[regex] = block
    end

    def call(string)
      matches = []
      items.each do |regex, block|
        matches << { :regex => regex, :block => block } if regex.match(string)
      end

      if matches.size == 1
        puts "\n  #{ YELLOW }Test Case: #{ GREEN }#{string}#{ NORMAL }"
        match = matches[0]
        match[:block].call(match[:regex], string)
      elsif matches.size > 1
        raise "Ambiguous test case match"
      else
        puts "\n  #{ YELLOW }Test Case: #{ RED }#{string} (undefined)#{ NORMAL }"
      end
    end
  end
end
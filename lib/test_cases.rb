module Norm
  class TestCases
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
        match = matches[0]
        match[:block].call(match[:regex], string)
      elsif matches.size > 1
        raise "Ambiguous match"
      else
        puts "Undefined test case '#{ string }'"
      end
    end
  end
end
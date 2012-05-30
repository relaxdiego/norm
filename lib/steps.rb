require 'singleton'

module Norm
  class Steps
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
      matched_items = []
      items.each do |regex, block|
        matched_items << { :regex => regex, :block => block } if regex.match(string)
      end

      if matched_items.size == 1
        puts "    #{ YELLOW }Step #{ GREEN }#{string}#{ NORMAL }"
        item = matched_items[0]
        vars = item[:regex].match(string)

        if vars.length > 1
          item[:block].call(*vars[1..-1])
        else
          item[:block].call
        end
      elsif matched_items.size > 1
        raise "Ambiguous step match"
      else
        puts "    #{ YELLOW }Step #{ RED }#{ string } (undefined)#{ NORMAL }"
      end
    end
  end
end
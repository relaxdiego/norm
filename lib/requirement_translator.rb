module Norm

  module RequirementTranslator
    REQUIREMENT = "Requirement"
    EXAMPLES    = "Examples"

    def self.translate(string)
      string.strip!

      position            = 0
      ruby_code           = ""
      in_header           = false
      in_examples         = false
      requirements_buffer = []
      requirement_id_part = ""
      examples            = []

      while position < string.size
        chunk = string[position..-1]

        if section_marker = chunk[/\A(\s*[A-Z].*:)/, 1]
          type = section_marker.strip.gsub(/:$/, '')

          if type == REQUIREMENT
            if requirement_id_part.size > 0 && in_header
              requirements_buffer << requirement_id_part.strip
              requirement_id_part = ""
            elsif requirement_id_part.size > 0 && in_examples
              examples.each do |row|
                requirements_buffer << translate_variables(requirement_id_part, row)
              end
              requirement_id_part = ""
              examples = []
            end

            if in_header
              ruby_code = flush_requirements_buffer(ruby_code, requirements_buffer)
              requirements_buffer = []
            end
          end

          in_header =
            in_examples = false

          if type == REQUIREMENT
            in_header = true
          elsif type == EXAMPLES
            in_examples  = true
            in_first_row = true
          else
            raise "Unknown section marker '#{ type }'"
          end

          position += section_marker.size
        elsif in_header
          if requirement_id = chunk[/\A(\s.+)/, 1]
            requirement_id_part << "#{ requirement_id.strip } "
            position += requirement_id.size
          end
        elsif in_examples
          row = nil
          row_str = chunk[/\A(\s*[\|-].*)/, 1]

          if row_str && row_str !~ /(\|-+)+\|/ && row_str !~ /-+/
            row = row_str.split('|').map{ |i| i.strip }.select{|i| i.size > 0}
          end

          if in_first_row && row
            header_row = row
            in_first_row = false
          elsif row
            values = row
            row_elements = {}
            (header_row.size).times do |i|
              row_elements[header_row[i]] = values[i]
            end
            examples << row_elements
          end
          position += row_str.size
        elsif file_header = chunk[/\A(.*?\n=+)/, 1]
          position += file_header.size
        end
        position += 1
      end

      if requirement_id_part.size > 0 && in_header
        requirements_buffer << requirement_id_part.strip
      elsif requirement_id_part.size > 0 && in_examples
        examples.each do |row|
          requirements_buffer << translate_variables(requirement_id_part, row)
        end
      end

      if in_header || in_examples
        ruby_code = flush_requirements_buffer(ruby_code, requirements_buffer)
      end

      ruby_code
    end

    private

    def self.flush_requirements_buffer(code, buffer)
      buffer.each do |requirement|
        code << "TestCases.call('#{ requirement }')\n"
      end
      code
    end

    def self.translate_variables(template, data)
      str = template.dup
      data.each do |key, value|
        str.gsub!("<#{ key }>", value)
      end
      str.strip
    end

  end

end
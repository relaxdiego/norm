require 'test_case'

class TestCaseTranslator
  TEST_CASE     = "Test Case"
  VARIABLES     = "Variables"
  PRECONDITIONS = "Preconditions"
  SCRIPT        = "Script"
  CLEANUP       = "Cleanup"

  def translate(string)
    string.strip!

    position = 0

    ruby_code = ""
    in_header =
      in_body =
      in_variables = false
    variables = {}

    while position < string.size
      chunk = string[position..-1]

      if section_marker = chunk[/\A(\s*[A-Z].*:)/, 1]
        type = section_marker.strip.gsub(/:$/, '')

        if in_header && type == TEST_CASE
          ruby_code = end_test_case_header(ruby_code)
          ruby_code = end_test_case(ruby_code)
          ruby_code << "\n"
        elsif in_header && [VARIABLES, PRECONDITIONS, SCRIPT, CLEANUP].include?(type)
          ruby_code = end_test_case_header(ruby_code)
        end

        if type == TEST_CASE
          ruby_code << "TestCases.add(/^"
          in_header = true
        elsif type == VARIABLES
          in_header = false
          in_body = in_variables = true
          variables = {}
        elsif type == PRECONDITIONS
          in_variables = false
          in_preconditions = true
        else
          raise "Unknown section marker '#{ type }'"
        end
        position += section_marker.size
      elsif in_header
        if test_case_id = chunk[/\A(\s*.+)/, 1]
          ruby_code << "#{ test_case_id.strip } "
          position += test_case_id.size
        end
      elsif in_variables && variable_def = chunk[/\A(\s*.+=.+)/, 1]
        name, value = split_variable_def(variable_def)
        variables[name] = value
        position += variable_def.size
      elsif in_preconditions && step = chunk[/\A(\s*\* .+)/, 1]
        rx_str = step.gsub(/^\s*\* /, '')
        ruby_code << "  Steps.call(\"#{ translate_vars(rx_str, variables) }\")\n"
        position += step.size
      end

      position += 1
    end

    if in_header
      ruby_code = end_test_case_header(ruby_code)
      in_header = false
    end

    ruby_code = end_test_case(ruby_code)

    ruby_code
  end

  private

  def end_test_case(code)
    code << "end\n"
    code
  end

  def end_test_case_header(code)
    code.strip!
    code << "$/i) do\n"
    code
  end

  def split_variable_def(variable_def)
    variable_pair = variable_def.split('=')
    return variable_pair[0].strip, variable_pair[1].strip
  end

  def translate_vars(string, variables)
    if match = /<([A-Za-z ]+)>/.match(string)
      xlated = ""
      (match.length-1).times do |i|
        xlated += string.gsub("<#{ match[i+1] }>", "\" + #{ variables[match[i+1]] }.to_s + \"")
      end
    else
      xlated = string + "\""
    end
    xlated
  end

end
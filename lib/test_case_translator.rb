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
      in_variables =
      in_preconditions =
      in_script =
      in_cleanup = false
    variables = {}

    while position < string.size
      chunk = string[position..-1]

      if section_marker = chunk[/\A(\s*[A-Z].*:)/, 1]
        type = section_marker.strip.gsub(/:$/, '')

        if type == TEST_CASE && in_header
          ruby_code = end_test_case_header(ruby_code)
          ruby_code = end_steps(ruby_code)
          ruby_code = end_test_case(ruby_code)
          ruby_code << "\n"
        elsif [VARIABLES, PRECONDITIONS, SCRIPT, CLEANUP].include?(type) && in_header
          ruby_code = end_test_case_header(ruby_code)
        elsif type == CLEANUP && (in_variables || in_preconditions || in_script)
          ruby_code << "  ensure\n"
        elsif type == TEST_CASE && (in_variables || in_preconditions || in_script)
          ruby_code = end_steps(ruby_code)
          ruby_code = end_test_case(ruby_code)
          ruby_code << "\n"
        elsif type == TEST_CASE && in_cleanup
          ruby_code = end_cleanup_section(ruby_code)
          ruby_code = end_test_case(ruby_code)
          ruby_code << "\n"
        end

        in_header =
          in_variables =
          in_preconditions =
          in_script =
          in_cleanup = false

        if type == TEST_CASE
          ruby_code << "test_cases.add(/^"
          in_header = true
        elsif type == VARIABLES
          in_variables = true
          variables    = {}
        elsif type == PRECONDITIONS
          in_preconditions = true
        elsif type == SCRIPT
          in_script = true
        elsif type == CLEANUP
          in_cleanup = true
        else
          raise "Unknown section marker '#{ type }'"
        end
        position += section_marker.size
      elsif in_header
        if test_case_id = chunk[/\A(\s*.+)/, 1]
          ruby_code << "#{ test_case_id.strip } "
          position += test_case_id.size
        end
      elsif in_variables && variable_def = chunk[/\A(\s*\**\s*.+=.+)/, 1]
        str = variable_def.gsub(/\A\s*\**\s*/, '')
        name, value = split_variable_def(str)
        variables[name] = value
        position += variable_def.size
      elsif (in_preconditions || in_script || in_cleanup) && step = chunk[/\A(\s*\**\s*.+)/, 1]
        str = step.gsub(/\A\s*\**\s*/, '')
        ruby_code << "    steps.call(\"#{ translate_vars(str, variables) }\")\n"
        position += step.size
      end

      position += 1
    end

    if in_header
      ruby_code = end_test_case_header(ruby_code)
      ruby_code = end_steps(ruby_code)
    end

    if in_variables || in_preconditions || in_script
      ruby_code = end_steps(ruby_code)
    elsif in_cleanup
      ruby_code = end_cleanup_section(ruby_code)
    end

    ruby_code = end_test_case(ruby_code)

    ruby_code
  end

  private

  def end_cleanup_section(code)
    code << "  end\n"
  end

  def end_steps(code)
    code << "  ensure\n  end\n"
    code
  end

  def end_test_case(code)
    code << "end\n"
    code
  end

  def end_test_case_header(code)
    code.strip!
    code << "$/i) do |regex, string|\n"
    code << "  regex.match(string)\n\n"
    code << "  begin\n"
    code
  end

  def split_variable_def(variable_def)
    variable_pair = variable_def.split('=')
    return variable_pair[0].strip, variable_pair[1].strip
  end

  def translate_vars(string, variables)
    string.scan(/<([A-Z].*?)>/).each do |match|
      string = string.gsub("<#{ match[0] }>", "\" + #{ variables[match[0]] }.to_s + \"")
    end
    string
  end

end
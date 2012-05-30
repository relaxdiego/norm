require_relative 'test_case_translator'

module Norm

  class Runtime
    attr_reader :root_path, :output_path, :test_cases_path

    def initialize(root_path)
      @root_path       = root_path
      @output_path     = File.join(root_path, 'output')
      @test_cases_path = File.join(root_path, 'test_cases')
    end

    def process_test_cases
      ensure_output_dir

      Dir.entries(test_cases_path).each do |file_name|
        /\w+\.test_cases$/.match(file_name) do |match|
          file     = File.open(File.join(test_cases_path, match[0]), 'rb')
          contents = TestCaseTranslator.translate(file.read)
          file.close

          file = File.new(File.join(output_path, match[0] + ".rb"), 'w')
          file.write(contents)
          file.close
        end
      end
    end

    private

    def ensure_output_dir
      Dir.mkdir(output_path) unless Dir.exists?(output_path)
    end
  end

end
require "test_helper"
require "runtime"

class RuntimeTests < Test::Unit::TestCase
  include Norm

  def test_processing_of_test_cases
    directives_path = File.expand_path("../samples", __FILE__)
    runtime = Runtime.new(directives_path)
    runtime.process_test_cases

    assert Dir.exists?(File.join(directives_path, '..', 'output')), 'Output directory was not created'

    Dir.entries(File.join(directives_path, 'test_cases')).each do |entry|
      rb_file_path = File.join(directives_path, '..', 'output', entry.gsub('.test_cases', '.test_cases.rb'))
      assert File.exists?(rb_file_path), "#{ rb_file_path } does not exist"
    end
  end

  def test_processing_of_requirements
    directives_path = File.expand_path("../samples", __FILE__)
    runtime = Runtime.new(directives_path)
    runtime.process_requirements

    assert Dir.exists?(File.join(directives_path, '..', 'output')), 'Output directory was not created'

    Dir.entries(File.join(directives_path, 'requirements')).each do |entry|
      rb_file_path = File.join(directives_path, '..', 'output', entry.gsub('.requirements', '.requirements.rb'))
      assert File.exists?(rb_file_path), "#{ rb_file_path } does not exist"
    end
  end

end
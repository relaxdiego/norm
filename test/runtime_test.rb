require "test_helper"
require "runtime"

class TestNorm < Test::Unit::TestCase
  include Norm

  def test_processing_of_test_cases
    root_path = File.expand_path("../samples", __FILE__)
    norm = Runtime.new(root_path)
    norm.process_test_cases

    assert Dir.exists?(File.join(root_path, 'output')), 'Output directory was not created'

    Dir.entries(File.join(root_path, 'test_cases')).each do |entry|
      rb_file_path = File.join(root_path, 'output', entry.gsub('.test_cases', '.test_cases.rb'))
      assert File.exists?(rb_file_path), "#{ rb_file_path } does not exist"
    end
  end

end
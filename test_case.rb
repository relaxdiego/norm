class TestCase
  attr_reader :regexp

  def initialize(regexp)
    @regexp = regexp
  end

  def ==(other_test_case)
    @regexp == other_test_case.regexp
  end
end
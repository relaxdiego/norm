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

    raise "Ambiguous match" if matches.size > 1
    match = matches[0]

    match[:block].call(match[:regex], string)
  end
end

test_cases = TestCases.new

test_cases.add(/^A user with a role of (.+) in the system can create a project$/i) do |regex, string|
  regex.match(string)

  begin
    steps.call("I have a role of " + $1.to_s + " in the system")

    steps.call("Click the Logout button if I'm currently logged in")
    steps.call("Fill in the Username field with " + my_username.to_s)
    steps.call("Fill in the Password field with " + my_password.to_s)
    steps.call("Click the Login button")
    steps.call("Click the Projects link")
    steps.call("Click the New Project button")
    steps.call("Fill in the Project Name field with " + 'test'.to_s)
    steps.call("Fill in the Project Description field with 'Test project'")
    steps.call("Click the Create Project button")
    steps.call("A project named " + 'test'.to_s + " should be visible in the page")
    steps.call("The project should exist in the backend cloud")
  ensure
    steps.call("Delete the project named " + 'test'.to_s + " if it exists")
    steps.call("Delete my username at exit")
  end
end

test_cases.call("A user with a role of System Admin in the system can create a project")
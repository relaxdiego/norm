require "test_helper"
require "test_case_translator"

class TestCaseTranslatorTests < Test::Unit::TestCase
  include Norm

  def test_single_line_test_case_name
    source_file = <<-EOF
Test Case:
  A user with a role of User in the system can create a project

EOF

    target_file = <<-EOF
TestCases.add(/^A user with a role of User in the system can create a project$/i) do |regex, string|
  regex.match(string)

  begin
  ensure
  end
end
EOF

    assert_equal target_file, TestCaseTranslator.translate(source_file)
  end

  def test_multiline_test_case_name
    source_file = <<-EOF
Test Case:
  A user with a role of
  (.+) in the system
  can create a project



EOF

    target_file = <<-EOF
TestCases.add(/^A user with a role of (.+) in the system can create a project$/i) do |regex, string|
  regex.match(string)

  begin
  ensure
  end
end
EOF

    assert_equal target_file, TestCaseTranslator.translate(source_file)
  end

  def test_multiple_test_cases
    source_file = <<-EOF
Test Case:
  A user with a role of (.+) in the system can create a project



Test Case:
  A user cannot create a project
EOF

    target_file = <<-EOF
TestCases.add(/^A user with a role of (.+) in the system can create a project$/i) do |regex, string|
  regex.match(string)

  begin
  ensure
  end
end

TestCases.add(/^A user cannot create a project$/i) do |regex, string|
  regex.match(string)

  begin
  ensure
  end
end
EOF
    assert_equal target_file, TestCaseTranslator.translate(source_file)
  end

  def test_variable_substitution
    source_file = <<-EOF
Test Case:
  A user with a role of (.+) in the system can create a project

  Variables:
    Role Name = $1

  Preconditions:
    * I have a role of <Role Name> in the system
EOF

    target_file = <<-EOF
TestCases.add(/^A user with a role of (.+) in the system can create a project$/i) do |regex, string|
  regex.match(string)

  begin
    Steps.call("I have a role of " + $1.to_s + " in the system")
  ensure
  end
end
EOF

    assert_equal target_file, TestCaseTranslator.translate(source_file)
  end

  def test_variable_substitution_2
    source_file = <<-EOF
Test Case:
  A user with a role of (.+) in the system can create a project

  Variables:
    Role Name = $1

  Preconditions:
    * I have a role of <Role Name> in the system <Role Name>
    * I have a role of <Role Name> in the system <Role Name>
EOF

    target_file = <<-EOF
TestCases.add(/^A user with a role of (.+) in the system can create a project$/i) do |regex, string|
  regex.match(string)

  begin
    Steps.call("I have a role of " + $1.to_s + " in the system " + $1.to_s + "")
    Steps.call("I have a role of " + $1.to_s + " in the system " + $1.to_s + "")
  ensure
  end
end
EOF

    assert_equal target_file, TestCaseTranslator.translate(source_file)
  end

  def test_multiple_variable_substitution
    source_file = <<-EOF
Test Case:
  A user with a role of (.+) in the system can create a project

  Variables:
    Role Name = $1
    A Variable = 'test'

  Preconditions:
    * I have a role of <Role Name> in the system <A Variable>
EOF

    target_file = <<-EOF
TestCases.add(/^A user with a role of (.+) in the system can create a project$/i) do |regex, string|
  regex.match(string)

  begin
    Steps.call("I have a role of " + $1.to_s + " in the system " + 'test'.to_s + "")
  ensure
  end
end
EOF

    assert_equal target_file, TestCaseTranslator.translate(source_file)
  end

  def test_preconditions_section
    source_file = <<-EOF
Test Case:
  A user with a role of (.+) in the system can create a project

  Preconditions:
    * I have a role of System Admin
EOF

    target_file = <<-EOF
TestCases.add(/^A user with a role of (.+) in the system can create a project$/i) do |regex, string|
  regex.match(string)

  begin
    Steps.call("I have a role of System Admin")
  ensure
  end
end
EOF

    assert_equal target_file, TestCaseTranslator.translate(source_file)
  end

  def test_script_section
    source_file = <<-EOF
Test Case:
  A user with a role of (.+) in the system can create a project

  Script:
    * I have a role of System Admin
EOF

    target_file = <<-EOF
TestCases.add(/^A user with a role of (.+) in the system can create a project$/i) do |regex, string|
  regex.match(string)

  begin
    Steps.call("I have a role of System Admin")
  ensure
  end
end
EOF

    assert_equal target_file, TestCaseTranslator.translate(source_file)
  end

  def test_cleanup_section
    source_file = <<-EOF
Test Case:
  A user with a role of (.+) in the system can create a project

  Script:
    * I have a role of System Admin

  Cleanup:
    * Delete my username at exit
EOF

    target_file = <<-EOF
TestCases.add(/^A user with a role of (.+) in the system can create a project$/i) do |regex, string|
  regex.match(string)

  begin
    Steps.call("I have a role of System Admin")
  ensure
    Steps.call("Delete my username at exit")
  end
end
EOF

    assert_equal target_file, TestCaseTranslator.translate(source_file)
  end

  def test_full_test_case_translation
    source_file = <<-EOF
Test Case:
  A user with a role of (.+) in the system can create a project

  Variables:
    * Role Name = $1
    * Project Name = 'test'
    * My Username  = my_username
    * My Password  = my_password

  Preconditions:
    * I have a role of <Role Name> in the system

  Script:
    * Click the Logout button if I'm currently logged in
    * Fill in the Username field with <My Username>
    * Fill in the Password field with <My Password>
    * Click the Login button
    * Click the Projects link
    * Click the New Project button
    * Fill in the Project Name field with <Project Name>
    * Fill in the Project Description field with 'Test project'
    * Click the Create Project button
    * A project named <Project Name> should be visible in the page
    * The project should exist in the backend cloud

  Cleanup:
    * Delete the project named <Project Name> if it exists
    * Delete my username at exit


EOF

    target_file = <<-EOF
TestCases.add(/^A user with a role of (.+) in the system can create a project$/i) do |regex, string|
  regex.match(string)

  begin
    Steps.call("I have a role of " + $1.to_s + " in the system")
    Steps.call("Click the Logout button if I'm currently logged in")
    Steps.call("Fill in the Username field with " + my_username.to_s + "")
    Steps.call("Fill in the Password field with " + my_password.to_s + "")
    Steps.call("Click the Login button")
    Steps.call("Click the Projects link")
    Steps.call("Click the New Project button")
    Steps.call("Fill in the Project Name field with " + 'test'.to_s + "")
    Steps.call("Fill in the Project Description field with 'Test project'")
    Steps.call("Click the Create Project button")
    Steps.call("A project named " + 'test'.to_s + " should be visible in the page")
    Steps.call("The project should exist in the backend cloud")
  ensure
    Steps.call("Delete the project named " + 'test'.to_s + " if it exists")
    Steps.call("Delete my username at exit")
  end
end
EOF

    assert_equal target_file, TestCaseTranslator.translate(source_file)
  end

  def test_translation_of_two_full_test_cases
    source_file = <<-EOF
Test Case:
  A user with a role of (.+) in the system can create a project

  Variables:
    * Role Name    = $1
    * Project Name = 'test'
    * My Username  = my_username
    * My Password  = my_password

  Preconditions:
    * I have a role of <Role Name> in the system

  Script:
    * Click the Logout button if I'm currently logged in
    * Fill in the Username field with <My Username>
    * Fill in the Password field with <My Password>
    * Click the Login button
    * Click the Projects link
    * Click the New Project button
    * Fill in the Project Name field with <Project Name>
    * Fill in the Project Description field with 'Test project'
    * Click the Create Project button
    * A project named <Project Name> should be visible in the page
    * The project should exist in the backend cloud

  Cleanup:
    * Delete the project named <Project Name> if it exists
    * Delete my username at exit

Test Case:
  A user with a role of (.+) in the system cannot create a project

  Variables:
    Role Name    = $1
    Project Name = 'test'
    My Username  = my_username
    My Password  = my_password

  Preconditions:
    * I have a role of <Role Name> in the system

  Script:
    * Click the Logout button if I'm currently logged in
    * Fill in the Username field with <My Username>
    * Fill in the Password field with <My Password>
    * Click the Login button
    * The Projects link should not exist

  Cleanup:
    * Delete my username at exit
EOF

    target_file = <<-EOF
TestCases.add(/^A user with a role of (.+) in the system can create a project$/i) do |regex, string|
  regex.match(string)

  begin
    Steps.call("I have a role of " + $1.to_s + " in the system")
    Steps.call("Click the Logout button if I'm currently logged in")
    Steps.call("Fill in the Username field with " + my_username.to_s + "")
    Steps.call("Fill in the Password field with " + my_password.to_s + "")
    Steps.call("Click the Login button")
    Steps.call("Click the Projects link")
    Steps.call("Click the New Project button")
    Steps.call("Fill in the Project Name field with " + 'test'.to_s + "")
    Steps.call("Fill in the Project Description field with 'Test project'")
    Steps.call("Click the Create Project button")
    Steps.call("A project named " + 'test'.to_s + " should be visible in the page")
    Steps.call("The project should exist in the backend cloud")
  ensure
    Steps.call("Delete the project named " + 'test'.to_s + " if it exists")
    Steps.call("Delete my username at exit")
  end
end

TestCases.add(/^A user with a role of (.+) in the system cannot create a project$/i) do |regex, string|
  regex.match(string)

  begin
    Steps.call("I have a role of " + $1.to_s + " in the system")
    Steps.call("Click the Logout button if I'm currently logged in")
    Steps.call("Fill in the Username field with " + my_username.to_s + "")
    Steps.call("Fill in the Password field with " + my_password.to_s + "")
    Steps.call("Click the Login button")
    Steps.call("The Projects link should not exist")
  ensure
    Steps.call("Delete my username at exit")
  end
end
EOF

    assert_equal target_file, TestCaseTranslator.translate(source_file)
  end

  def test_translation_of_two_incomplete_tests
    source_file = <<-EOF
Test Case:
  A user with a role of (.+) in the system can create a project

  Variables:
    * Role Name    = $1
    * Project Name = 'test'
    * My Username  = my_username
    * My Password  = my_password

  Preconditions:
    * I have a role of <Role Name> in the system

  Script:
    * Click the Logout button if I'm currently logged in
    * Fill in the Username field with <My Username>
    * Fill in the Password field with <My Password>
    * Click the Login button
    * Click the Projects link
    * Click the New Project button
    * Fill in the Project Name field with <Project Name>
    * Fill in the Project Description field with 'Test project'
    * Click the Create Project button
    * A project named <Project Name> should be visible in the page
    * The project should exist in the backend cloud

Test Case:
  A user with a role of (.+) in the system cannot create a project
EOF

    target_file = <<-EOF
TestCases.add(/^A user with a role of (.+) in the system can create a project$/i) do |regex, string|
  regex.match(string)

  begin
    Steps.call("I have a role of " + $1.to_s + " in the system")
    Steps.call("Click the Logout button if I'm currently logged in")
    Steps.call("Fill in the Username field with " + my_username.to_s + "")
    Steps.call("Fill in the Password field with " + my_password.to_s + "")
    Steps.call("Click the Login button")
    Steps.call("Click the Projects link")
    Steps.call("Click the New Project button")
    Steps.call("Fill in the Project Name field with " + 'test'.to_s + "")
    Steps.call("Fill in the Project Description field with 'Test project'")
    Steps.call("Click the Create Project button")
    Steps.call("A project named " + 'test'.to_s + " should be visible in the page")
    Steps.call("The project should exist in the backend cloud")
  ensure
  end
end

TestCases.add(/^A user with a role of (.+) in the system cannot create a project$/i) do |regex, string|
  regex.match(string)

  begin
  ensure
  end
end
EOF

    assert_equal target_file, TestCaseTranslator.translate(source_file)
  end
end
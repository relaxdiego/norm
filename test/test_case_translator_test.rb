require "test_helper"
require "test_case_translator"

class TestCaseTranslatorTest < Test::Unit::TestCase
  def test_single_line_test_case_name
    source_file = <<-EOF
Test Case:
  A user with a role of User in the system can create a project

EOF

    target_file = <<-EOF
TestCases.add(/^A user with a role of User in the system can create a project$/i) do
end
EOF

    assert_equal target_file, TestCaseTranslator.new.translate(source_file)
  end

  def test_multiline_test_case_name
    source_file = <<-EOF
Test Case:
  A user with a role of
  (.+) in the system
  can create a project



EOF

    target_file = <<-EOF
TestCases.add(/^A user with a role of (.+) in the system can create a project$/i) do
end
EOF

    assert_equal target_file, TestCaseTranslator.new.translate(source_file)
  end

  def test_multiple_test_cases
    source_file = <<-EOF
Test Case:
  A user with a role of (.+) in the system can create a project



Test Case:
  A user cannot create a project
EOF

    target_file = <<-EOF
TestCases.add(/^A user with a role of (.+) in the system can create a project$/i) do
end

TestCases.add(/^A user cannot create a project$/i) do
end
EOF
    assert_equal target_file, TestCaseTranslator.new.translate(source_file)
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
TestCases.add(/^A user with a role of (.+) in the system can create a project$/i) do
  Steps.call("I have a role of " + $1.to_s + " in the system")
end
EOF

    assert_equal target_file, TestCaseTranslator.new.translate(source_file)
  end

  def test_multiple_variable_substitution
    source_file = <<-EOF
Test Case:
  A user with a role of (.+) in the system can create a project

  Variables:
    Role Name = $1

  Preconditions:
    * I have a role of <Role Name> in the system <Role Name>
EOF

    target_file = <<-EOF
TestCases.add(/^A user with a role of (.+) in the system can create a project$/i) do
  Steps.call("I have a role of " + $1.to_s + " in the system " + $1.to_s + "")
end
EOF

    assert_equal target_file, TestCaseTranslator.new.translate(source_file)
  end


# #   def test_full_test_case_translation
# #     source_file = <<-EOF
# # Test Case:
# #   A user with a role of (.+) in the system can create a project
# #
# #   Variables:
# #     * Role Name    = $1
# #     * Project Name = 'test'
# #     * My Username  = my_username
# #     * My Password  = my_password
# #
# #   Preconditions:
# #     * I have a role of <Role Name> in the system
# #
# #   Script:
# #     * Click the Logout button if I'm currently logged in
# #     * Fill in the Username field with <My Username>
# #     * Fill in the Password field with <My Password>
# #     * Click the Login button
# #     * Click the Projects link
# #     * Click the New Project button
# #     * Fill in the Project Name field with <Project Name>
# #     * Fill in the Project Description field with 'Test project'
# #     * Click the Create Project button
# #     * A project named <Project Name> should be visible in the page
# #     * The project should exist in the backend cloud
# #
# #   Cleanup:
# #     * Delete the project named <Project Name> if it exists
# #     * Delete my username at exit
# #
# #
# # EOF
# #
# #     target_file = <<-EOF
# # TestCase /^A user with a role of (.+) in the system can create a project$/i do
# #     Steps.call("I have a role of " + $1.to_s + " in the system")
# #
# #     begin
# #       Steps.call("Click the Logout button if I'm currently logged in")
# #       Steps.call("Fill in the Username field with " + my_username.to_s)
# #       Steps.call("Fill in the Password field with " + my_password.to_s)
# #       Steps.call("Click the Login button")
# #       Steps.call("Click the Projects link")
# #       Steps.call("Click the New Project button")
# #       Steps.call("Fill in the Project Name field with " + 'test'.to_s)
# #       Steps.call("Fill in the Project Description field with 'Test project'")
# #       Steps.call("Click the Create Project button")
# #       Steps.call("A project named " + 'test'.to_s + " should be visible in the page")
# #       Steps.call("The project should exist in the backend cloud")
# #     ensure
# #       Steps.call("Delete the project named " + 'test'.to_s + " if it exists")
# #       Steps.call("Delete my username at exit")
# #     end
# #   end
# # EOF
# #
# #     assert_equal target_file, TestXlator.new.translate(source_file)
# #   end
end
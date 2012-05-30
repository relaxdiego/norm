require "test_helper"
require "requirement_translator"

class RequirementTranslatorTests < Test::Unit::TestCase
  include Norm

  def test_ignore_header
    input = <<-EOF
Create a Project
================
EOF
    output = <<-EOF
EOF
    assert_equal output, RequirementTranslator.translate(input)
  end

  def test_single_requirement
    input = <<-EOF
Create a Project
================

  Requirement:
    A user who is not a member of a project cannot view its contents
EOF
    output = <<-EOF
TestCases.call('A user who is not a member of a project cannot view its contents')
EOF
    assert_equal output, RequirementTranslator.translate(input)
  end

  def test_multiple_requirements
    input = <<-EOF
Create a Project
================

  Requirement:
    A user who is not a member of a project cannot view its contents

  Requirement:
    AAAA user who is a member of a project can view its contents
EOF
    output = <<-EOF
TestCases.call('A user who is not a member of a project cannot view its contents')
TestCases.call('AAAA user who is a member of a project can view its contents')
EOF
    assert_equal output, RequirementTranslator.translate(input)
  end

  def test_multiline_requirement
    input = <<-EOF
  Requirement:
    A user who is not a member
    of a project cannot view
    its contents


EOF
    output = <<-EOF
TestCases.call('A user who is not a member of a project cannot view its contents')
EOF
    assert_equal output, RequirementTranslator.translate(input)
  end

  def test_multiline_requirement_2
    input = <<-EOF
  Requirement:
    A user who is not a member
    of a project cannot view
    its contents

  Requirement:
    A user who is a member of a project can view its contents


EOF
    output = <<-EOF
TestCases.call('A user who is not a member of a project cannot view its contents')
TestCases.call('A user who is a member of a project can view its contents')
EOF
    assert_equal output, RequirementTranslator.translate(input)
  end

  def test_requirement_template
    input = <<-EOF
  Requirement:
    A user with a role of <Role> in the system <Can or Cannot Create> a project

    Examples:
      | Role  | Can or Cannot Create |
      | Admin | Can Create           |
      | User  | Cannot Create        |

EOF
    output = <<-EOF
TestCases.call('A user with a role of Admin in the system Can Create a project')
TestCases.call('A user with a role of User in the system Cannot Create a project')
EOF
    assert_equal output, RequirementTranslator.translate(input)
  end

  def test_multiple_requirement_template
    input = <<-EOF
  Requirement:
    A user with a role of <Role> in the system <Can or Cannot Create> a project

    Examples:
      | Role  | Can or Cannot Create |
      | Admin | Can Create           |
      | User  | Cannot Create        |

  Requirement:
    A user who is <A Member or Not> of a project <Can or Cannot View> its contents

    Examples:
      | A Member or Not | Can or Cannot View |
      | A Member        | Can View           |

EOF
    output = <<-EOF
TestCases.call('A user with a role of Admin in the system Can Create a project')
TestCases.call('A user with a role of User in the system Cannot Create a project')
TestCases.call('A user who is A Member of a project Can View its contents')
EOF
    assert_equal output, RequirementTranslator.translate(input)
  end

  def test_example_table_with_header_divider
    input = <<-EOF
  Requirement:
    A user with a role of <Role> in the system <Can or Cannot Create> a project

    Examples:
      | Role  | Can or Cannot Create |
      |-------|----------------------|
      | Admin | Can Create           |
      | User  | Cannot Create        |

EOF
    output = <<-EOF
TestCases.call('A user with a role of Admin in the system Can Create a project')
TestCases.call('A user with a role of User in the system Cannot Create a project')
EOF
    assert_equal output, RequirementTranslator.translate(input)
  end

  def test_example_table_with_borders
    input = <<-EOF
  Requirement:
    A user with a role of <Role> in the system <Can or Cannot Create> a project

    Examples:
      --------------------------------
      | Role  | Can or Cannot Create |
      |-------|----------------------|
      | Admin | Can Create           |
      | User  | Cannot Create        |
      --------------------------------

EOF
    output = <<-EOF
TestCases.call('A user with a role of Admin in the system Can Create a project')
TestCases.call('A user with a role of User in the system Cannot Create a project')
EOF
    assert_equal output, RequirementTranslator.translate(input)
  end


  def test_example_with_empty_cell
    input = <<-EOF
  Requirement:
    A user with a role of <Role> in the system <Can or Cannot Create> a project

    Examples:
      --------------------------------
      | Role  | Can or Cannot Create |
      |-------|----------------------|
      |       | Can Create           |
      | User  | Cannot Create        |
      --------------------------------

EOF
    output = <<-EOF
TestCases.call('A user with a role of  in the system Can Create a project')
TestCases.call('A user with a role of User in the system Cannot Create a project')
EOF
    assert_equal output, RequirementTranslator.translate(input)
  end

end
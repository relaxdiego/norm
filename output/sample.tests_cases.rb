TestCases.add(/^A user with a role of (.+) in the system can create a project$/i) do
  Steps.call("I have a role of " + $1.to_s + " in the system")

  begin
    Steps.call("Click the Logout button if I'm currently logged in")
    Steps.call("Fill in the Username field with " + my_username.to_s)
    Steps.call("Fill in the Password field with " + my_password.to_s)
    Steps.call("Click the Login button")
    Steps.call("Click the Projects link")
    Steps.call("Click the New Project button")
    Steps.call("Fill in the Project Name field with " + 'test'.to_s)
    Steps.call("Fill in the Project Description field with 'Test project'")
    Steps.call("Click the Create Project button")
    Steps.call("A project named " + 'test'.to_s + " should be visible in the page")
    Steps.call("The project should exist in the backend cloud")
  ensure
    Steps.call("Delete the project named " + 'test'.to_s + " if it exists")
    Steps.call("Delete my username at exit")
  end
end
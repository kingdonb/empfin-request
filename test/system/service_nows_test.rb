require "application_system_test_case"

class ServiceNowsTest < ApplicationSystemTestCase
  test 'login and submit a request, then visit the request item' do
    e = EmpfinRequestForm::Main.new(ctx: self)
    e.run
  end
end

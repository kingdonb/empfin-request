require "application_system_test_case"
require "modules/empfin_request_form"

class ServiceNowsTest < ApplicationSystemTestCase
  test 'login and submit a request, then visit the request item' do
    e = EmpfinRequestForm::Main.new(ctx: self)
    e.run
  end
end

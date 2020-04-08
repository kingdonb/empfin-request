require "application_system_test_case"

class ServiceNowsTest < ApplicationSystemTestCase
  # test 'login and submit a request, then visit the request item' do
  #   e = EmpfinRequestForm::Main.new(ctx: self)
  #   e.run
  # end
  test 'login and review services, then output a Diff csv' do
    e = EmpfinServiceReview::Main.new(ctx: self)
    e.run
  end
  # test 'login and review services, then reverse any Diffs from the csv' do
  #   e = EmpfinServiceReview::Main.new(ctx: self)
  #   e.run
  # end
end

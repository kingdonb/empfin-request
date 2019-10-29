require "application_system_test_case"
require "modules/empfin_request_form"

class ServiceNowsTest < ApplicationSystemTestCase
  test 'login and submit a request, then visit the request item' do
    EmpfinRequestForm::Login.new(ctx: self)

    # sanity check - did we land on the right form?
    iframe = find('main iframe#gsft_main', wait: 10)
    within_frame(iframe) do
      find('#item_table')
      find('table td.guide_tray', text: 'Customer Care Request')
    end

    f = EmpfinRequestForm::Fillout.
      new(ctx: self, iframe: iframe)

    f.fill_out(
      work: 'KB - This is a Test - Test of long text description - Please perform the following steps (test) Test - KB - TEST ONLY',
      group: 'Employee Finance Solutions',
      user: 'Kingdon Barrett'
    )

    ritm_no = f.submit
  end
end

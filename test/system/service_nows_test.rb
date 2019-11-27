require "application_system_test_case"
require "modules/empfin_request_form"

require 'smarter_csv'

class ServiceNowsTest < ApplicationSystemTestCase
  test 'login and submit a request, then visit the request item' do
    EmpfinRequestForm::Login.new(ctx: self)

    # sanity check - did we land on the right form?
    iframe = find('main iframe#gsft_main', wait: 10)
    within_frame(iframe) do
      find('#item_table')
      find('table td.guide_tray', text: 'Customer Care Request')
    end

    # SmarterCSV generates an array of hashes
    s = SmarterCSV.process('new-cc-file.csv')
    # We will take only the first element from the array, until we are
    # satisfied that the automated process captures everything and reacts
    # properly to data entry errors.
    row = s.first

    f = EmpfinRequestForm::Fillout.
      new(ctx: self, iframe: iframe)

    f.fill_out_with_row(row)
    # f.fill_out(
    #   work: 'KB - This is a Test - Test of long text description - Please perform the following steps (test) Test - KB - TEST ONLY',
    #   group: 'Employee Finance Solutions',
    #   user: 'Kingdon Barrett'
    # )

    # When submit returns, you either have obtained a req_no or failure
    req_no = f.submit
    follow_req_link(req_no)

    # Following the request link should lead you to a RITM with a single TASK
    ritm_link, ritm_no = f.find_ritm_number
    ritm_link.click

    # FIXME - Record those RITM and TASK numbers in an output CSV file,
    # * parse the item number from the original row, for traceability
    # * with the links and item number for each REQ, RITM, and TASK generated
    # * read this file too on startup, and filter any from the input list that
    #   were already processed

  end
end

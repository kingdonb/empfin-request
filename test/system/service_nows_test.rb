require "application_system_test_case"
require "modules/empfin_request_form"

require 'smarter_csv'

class ServiceNowsTest < ApplicationSystemTestCase
  test 'login and submit a request, then visit the request item' do
    EmpfinRequestForm::Login.new(ctx: self)

    find('#item_table')
    find('table td.guide_tray', text: 'Customer Care Request')

    o = SmarterCSV.process('output-cc-file.csv')
    s = SmarterCSV.process('orig-cc-file.csv')

    t = EmpfinRequestForm.filter_orig_by_output(orig: s, output: o)

    # We will take only the first element from the array, until we are
    # satisfied that the automated process captures everything and reacts
    # properly to data entry errors.
    row = t.first

    begin

      short_description = row[:short_description]

      output_row = EmpfinRequestForm.get_row_by_original_key(output: o, original_key: short_description)

      if output_row.present?
        # we have a work in progress output row
      else
        output_row = {:original_key=>short_description,
                      :on_behalf_of_department=>nil,
                      :original_id=>nil,
                      :business_application=>nil,
                      :req_id=>nil,
                      :ritm_id=>nil,
                      :task_id=>nil,
                      :req_url=>"",
                      :ritm_url=>"",
                      :task_url=>""}

        r = /^CC: (.*) -  #(\d+) (.*)$/
        m = r.match(short_description)

        on_behalf_of_department, original_id, business_application = m[1], m[2], m[3]
        output_row[:on_behalf_of_department] = on_behalf_of_department
        output_row[:original_id]             = original_id
        output_row[:business_application]    = business_application

        o << output_row
      end

    f = EmpfinRequestForm::Fillout.
      new(ctx: self, iframe: nil) # There is no iframe now! cool

    if output_row[:req_id].present?
      output_req_url = EmpfinRequestForm.get_url_by_req_id(output: o, req_id: output_row[:req_id])
    end

    if output_req_url.present?
      visit output_req_url
      req_url = output_req_url
    else
      f.fill_out_1_with_row(row)
      # When submit returns, you either have obtained a req_no or failure
      req_no = f.submit_1
      req_link_url = f.follow_req_link(req_no)
    end

    output_row[:req_id]  = req_no
    output_row[:req_url] = req_link_url

    binding.pry
    # Following the request link should lead you to a RITM with a single TASK
    ritm_link, ritm_no = f.find_ritm_number
    ritm_link.click

    task_link, task_no = f.find_task_number

    f.fill_out_2_with_row(row)
    f.submit_2

    # FIXME - Record those RITM and TASK numbers in an output CSV file,
    # * parse the item number from the original row, for traceability
    # * with the links and item number for each REQ, RITM, and TASK generated
    # * read this file too on startup, and filter any from the input list that
    #   were already processed

    ensure
      EmpfinRequestForm.to_csv(input_array: o, csv_filename: 'output-cc-file.csv')
      # write "o" back out to the file it came from
    end

  end
end

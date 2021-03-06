require 'smarter_csv'

module EmpfinRequestForm
  class Main
    attr_reader :ctx

    def initialize(ctx:)
      # instance of process
      @ctx = ctx
    end

    def run
      do_login
      validate_login_destination
      setup_csv_context

      main_loop
    end

    private

    attr_reader :login_handle

    def do_login
      @login_handle = EmpfinRequestForm::Login.new(ctx: ctx)
    end

    def validate_login_destination
      ctx.find('#item_table')
      ctx.find('table td.guide_tray', text: 'Customer Care Request')
    end

    attr_reader :o, :s, :t

    def setup_csv_context
      begin
        @o = SmarterCSV.process('output-cc-file.csv')
      rescue EOFError => e
        @o = []
      end
      @s = SmarterCSV.process('orig-cc-file.csv')

      @t = EmpfinRequestForm::RowReader.filter_orig_by_output(orig: s, output: o)
    end

    def main_loop
      t.each do |row|
        begin ## "t.each"

          short_description = row[:short_description]

          output_row = EmpfinRequestForm::RowReader.get_row_by_original_key(output: o, original_key: short_description)

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

            r = /^CC: (.*) - Priority: (.*) - #(\d+) (.*)$/
            m = r.match(short_description)

            on_behalf_of_department, priority, original_id, business_application = m[1], m[2], m[3], m[4]
            output_row[:on_behalf_of_department] = on_behalf_of_department
            output_row[:original_id]             = original_id
            output_row[:business_application]    = business_application

            o << output_row
          end

          f = EmpfinRequestForm::Fillout.
            new(ctx: ctx, iframe: nil) # There is no iframe now! cool

          if output_row[:req_id].present?
            req_no = output_row[:req_id]
            output_req_url = EmpfinRequestForm::RowReader.get_url_by_req_id(output: o, req_id: req_no)
          end

          if output_req_url.present?
            ctx.visit output_req_url
            req_link_url = output_req_url
          else
            f.fill_out_1_with_row(row)
            # When submit returns, you either have obtained a req_no or failure
            req_no = f.submit_1
            req_link_url = f.follow_req_link(req_no)
          end

          output_row[:req_id]  = req_no
          output_row[:req_url] = req_link_url

          # Following the request link should lead you to a RITM with a single TASK
          ritm_link, ritm_no = f.find_ritm_number
          output_row[:ritm_url] = ritm_link[:href]
          ritm_link.click

          # TASK contains everything important from here on, the RITM is not important
          task_link, task_no = f.find_task_number
          output_row[:task_url] = task_link[:href]
          task_link.click

          f.fill_out_2_with_row(row)
          f.submit_2

          output_row[:ritm_id] = ritm_no
          output_row[:task_id] = task_no

        ensure
          EmpfinRequestForm::CsvWriter.to_csv(input_array: o, csv_filename: 'output-cc-file.csv')
          # write "o" back out to the file it came from
        end

        login_handle.visit_request_url(ctx: ctx)

      end
      ## end "t.each"

    end
  end
end

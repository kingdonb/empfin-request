require 'smarter_csv'

module EmpfinServiceReview
  class Main
    include Support

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
      @login_handle = EmpfinServiceReview::Login.new(ctx: ctx)
    end

    def validate_login_destination
      # clear_search = ctx.find('a[aria-label="Remove next condition Keywords = alphasense"]')
      # clear_search.click
      ctx.find('h2.navbar-title.list_title', text: 'Business Applications')
      search_input
    end

    attr_reader :o, :s, :t

    def setup_csv_context
      options = { row_sep: "\n", col_sep: "," }
      # options = {}
      begin
        @o = SmarterCSV.process('output-srv-file.csv', options)
      rescue EOFError => e
        @o = []
      end
      @s = SmarterCSV.process('orig-srv-file.csv', options)

      @t = EmpfinServiceReview::RowReader.filter_orig_by_output(orig: s, output: o)
    end

    def main_loop
      t.each do |row|
        begin ## "t.each"

          name = row[:name]

          output_row = EmpfinServiceReview::RowReader.get_row_by_name(output: o, name: name)

          if output_row.present?
            # we have a work in progress output row
            # binding.pry
          else
            output_row = {:name=>name,
                          :already_compared=>'no',
                          :everything_matches=>nil,
                          :url=>""}

            # r = /^CC: (.*) - Priority: (.*) - #(\d+) (.*)$/
            # m = r.match(short_description)

            # on_behalf_of_department, priority, original_id, business_application = m[1], m[2], m[3], m[4]
            # output_row[:on_behalf_of_department] = on_behalf_of_department
            # output_row[:original_id]             = original_id
            # output_row[:business_application]    = business_application

            o << output_row
          end

          unless output_row[:already_compared] == "X"
            if output_row[:url].present?
              ctx.visit(output_row[:url])
            else
              login_handle.visit_request_url(ctx: ctx)
              # methods defined in Support module:
              search_for(name)
              open_record(name, ctx: ctx)
            end

            arrive_at_business_record(name, ctx: ctx, output_row: output_row)

            # the business happens in here:
            compare_shown_business_service_with_orig_srv_and_update_output(
              orig_row: row, output_row: output_row,
              business_app_name: name, ctx: ctx)

            if output_row[:everything_matches].blank?
              output_row[:everything_matches] = true
            end
            # binding.pry

            output_row[:already_compared] = 'X'

          end


        ensure
          EmpfinServiceReview::CsvWriter.to_csv(input_array: o, csv_filename: 'output-srv-file.csv')
          # write "o" back out to the file it came from
        end


      end
      ## end "t.each"

    end
  end
end

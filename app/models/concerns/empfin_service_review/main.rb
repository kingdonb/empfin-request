require 'smarter_csv'

module EmpfinServiceReview
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
      @login_handle = EmpfinServiceReview::Login.new(ctx: ctx)
    end

    def validate_login_destination
      clear_search = ctx.find('a[aria-label="Remove next condition Keywords = alphasense"]')
      clear_search.click
      ctx.find('h2.navbar-title.list_title', text: 'Business Applications')
      ctx.find('input[placeholder="Search"]')
    end

    attr_reader :o, :s, :t

    def setup_csv_context
      begin
        @o = SmarterCSV.process('output-srv-file.csv')
      rescue EOFError => e
        @o = []
      end
      @s = SmarterCSV.process('orig-srv-file.csv')

      @t = EmpfinServiceReview::RowReader.filter_orig_by_output(orig: s, output: o)
    end

    def main_loop
      t.each do |row|
        begin ## "t.each"
        ensure
          EmpfinServiceReview::CsvWriter.to_csv(input_array: o, csv_filename: 'output-srv-file.csv')
          # write "o" back out to the file it came from
        end

        login_handle.visit_request_url(ctx: ctx)

      end
      ## end "t.each"

    end
  end
end

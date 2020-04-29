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
      # read and prepare to reconcile
      t.each do |row|
        begin ## "t.each"
          name = row[:name]

          output_row = fetch_or_insert_output_row_from_o(o: o, name: name)

          perform_row_comparison_unless_marked_already_compared(
            row: row, output_row: output_row, name: name, ctx: ctx
          )
        rescue RecordNotFoundInBusinessAppSearch => e
          output_row[:already_compared] = 'missing'
        ensure
          EmpfinServiceReview::CsvWriter.to_csv(input_array: o, csv_filename: 'output-srv-file.csv')
          # write "o" back out to the file it came from
        end
      end

      # submit any updates to rows which were found to have changes needed, and
      # mark them as completed
      t.each do |row|
        begin
          name = row[:name]

          output_row = fetch_or_insert_output_row_from_o(o: o, name: name)

          perform_record_update_from_output_row_if_needed(
            row: row, output_row: output_row, name: name, ctx: ctx
          )
          output_row[:finalized] = 'X'
        ensure
          EmpfinServiceReview::CsvWriter.to_csv(input_array: o, csv_filename: 'output-srv-file.csv')
        end
      end
      ## end "t.each"

    end
  end
end

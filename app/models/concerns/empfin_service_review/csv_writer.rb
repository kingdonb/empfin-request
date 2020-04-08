require "csv"

module EmpfinServiceReview::CsvWriter
  module_function
  def to_csv(input_array:, csv_filename: "scratch-file.csv")
    CSV.open(csv_filename, "wb") do |csv|
      keys = input_array.first.keys
      # header_row
      csv << keys
      input_array.each do |hash|
        csv << hash.values_at(*keys)
      end
    end
  end
end

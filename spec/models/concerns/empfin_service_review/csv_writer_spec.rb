require 'rails_helper'

RSpec.describe EmpfinServiceReview::CsvWriter do
  context "writes to a file 'output-srv-file.csv'" do
    let(:input_array) { [{a: 'asdf', b: 'zxcv'}] }
    let(:scratch_filename) { 'scratch-file.csv' }
    describe '#to_csv' do
      it 'writes a CSV' do
        expect(CSV).to receive(:open).with(scratch_filename, 'wb', {:col_sep=>",", :row_sep=>"\n"}).and_call_original
        described_class.to_csv(input_array: input_array)

        txt = File.read(scratch_filename)
        expect(txt).to eq(<<~CSV
          a,b
          asdf,zxcv
          CSV
        )
      end
    end
  end
end

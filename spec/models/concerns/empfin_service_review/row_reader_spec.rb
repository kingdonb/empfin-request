require 'rails_helper'

RSpec.describe EmpfinServiceReview::RowReader do
  let(:input_rows) { [
      {short_description: 'abc', extra_data: '123'},
      {short_description: 'def', extra_data: '789'},
      {short_description: 'ghi', extra_data: '012'}
    ] }
  let(:not_matched_input_rows) { [
      {short_description: 'def', extra_data: '789'},
      {short_description: 'ghi', extra_data: '012'}
    ] }

  let(:row_to_include) { {short_description: 'ghi', extra_data: '012'} }
  let(:row_to_not_include) { {short_description: 'abc', extra_data: '123'} }

  let(:output_rows) { [
      {name: 'abc', extra_data: '123', url: 'https://foofoo',
       req_id: 'REQ0001', ritm_id: 'RITM0001', task_id: 'TASK0001'},
      {name: 'ghi', extra_data: '012', url: 'https://foofoo3',
       req_id: 'REQ0003', ritm_id: '', task_id: ''}
    ] }
  let(:bad_output_rows) { [
      {name: 'abc', extra_data: '123', url: 'https://foofoo',
       req_id: 'REQ0001', ritm_id: 'RITM0001', task_id: 'TASK0001'},
      {name: 'abc', extra_data: '123', url: 'https://foofoo2',
       req_id: 'REQ0002', ritm_id: 'RITM0002', task_id: 'TASK0002'}
    ] }

  context "module_functions" do
    context "reads values from output rows" do
      it '#get_row_by_name' do
        o = EmpfinServiceReview::RowReader.get_row_by_name(
          output: output_rows, name: 'abc'
        )
        expect(o).to eq({
          name: 'abc', extra_data: '123',
          url: 'https://foofoo', req_id: 'REQ0001',
          ritm_id: "RITM0001", task_id: "TASK0001",
        })
      end
      it '#get_url_by_name' do
        u = EmpfinServiceReview::RowReader.get_url_by_name(
          output: output_rows, name: 'abc'
        )
        expect(u).to eq('https://foofoo')
      end
    end
    xcontext "narrows the input data with information from output file" do
      describe '#filter_orig_by_output' do
        it 'uses :name as the value to join with :short_description' do
          f = EmpfinServiceReview::RowReader.filter_orig_by_output(
            orig: input_rows, output: output_rows
          )
          expect(f).to eq not_matched_input_rows
        end
        it 'crashes whenever output array does not maintain primacy' do
          expect{
            EmpfinServiceReview::RowReader.filter_orig_by_output(
            orig: input_rows, output: bad_output_rows)
          }.to raise_error NoMethodError, "undefined method `flunk' for EmpfinServiceReview::RowReader:Module"
        end
        it 'rejects a record from the input set when all three ids are present' do
          f = EmpfinServiceReview::RowReader.filter_orig_by_output(
            orig: input_rows, output: output_rows
          )

          expect(f).to include row_to_include
          expect(f).not_to include row_to_not_include
        end
      end
    end
  end
end

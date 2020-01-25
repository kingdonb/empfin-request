require 'rails_helper'

RSpec.describe EmpfinRequestForm::RowReader do
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
      {original_key: 'abc', extra_data: '123', req_url: 'https://foofoo',
       req_id: 'REQ0001', ritm_id: 'RITM0001', task_id: 'TASK0001'},
      {original_key: 'ghi', extra_data: '012', req_url: 'https://foofoo3',
       req_id: 'REQ0003', ritm_id: '', task_id: ''}
    ] }
  let(:bad_output_rows) { [
      {original_key: 'abc', extra_data: '123', req_url: 'https://foofoo',
       req_id: 'REQ0001', ritm_id: 'RITM0001', task_id: 'TASK0001'},
      {original_key: 'abc', extra_data: '123', req_url: 'https://foofoo2',
       req_id: 'REQ0002', ritm_id: 'RITM0002', task_id: 'TASK0002'}
    ] }

  context "module_functions" do
    context "reads values from output rows" do
      it '#get_row_by_original_key' do
        o = EmpfinRequestForm::RowReader.get_row_by_original_key(
          output: output_rows, original_key: 'abc'
        )
        expect(o).to eq({
          original_key: 'abc', extra_data: '123',
          req_url: 'https://foofoo', req_id: 'REQ0001',
          ritm_id: "RITM0001", task_id: "TASK0001",
        })
      end
      it '#get_url_by_req_id' do
        u = EmpfinRequestForm::RowReader.get_url_by_req_id(
          output: output_rows, req_id: 'REQ0001'
        )
        expect(u).to eq('https://foofoo')
      end
    end
    context "narrows the input data with information from output file" do
      describe '#filter_orig_by_output' do
        it 'uses :original_key as the value to join with :short_description' do
          f = EmpfinRequestForm::RowReader.filter_orig_by_output(
            orig: input_rows, output: output_rows
          )
          expect(f).to eq not_matched_input_rows
        end
        it 'crashes whenever output array does not maintain primacy' do
          expect{
            EmpfinRequestForm::RowReader.filter_orig_by_output(
            orig: input_rows, output: bad_output_rows)
          }.to raise_error NoMethodError, "undefined method `flunk' for EmpfinRequestForm::RowReader:Module"
        end
        it 'rejects a record from the input set when all three ids are present' do
          f = EmpfinRequestForm::RowReader.filter_orig_by_output(
            orig: input_rows, output: output_rows
          )

          expect(f).to include row_to_include
          expect(f).not_to include row_to_not_include
        end
      end
    end
  end
end

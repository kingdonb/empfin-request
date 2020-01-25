require 'rails_helper'

RSpec.describe EmpfinRequestForm::RowReader do
  context "module_functions" do
    context "reads values from output rows" do
      it '#get_row_by_original_key' do
        pending 'retrieves the entire row from output when original_key matches'
      end
      it '#get_url_by_req_id' do
        pending 'fetch only the request URL from output, with a req_no'
      end
    end
    context "narrows the input data with information from output file" do
      describe '#filter_orig_by_output' do
        it 'uses :original_key as the value to join columns on' do
          pending
        end
        it 'crashes whenever output array does not maintain primacy' do
          pending
        end
        it 'rejects a record from the input set when all three ids are present' do
          pending
        end
      end
    end
  end
end

module EmpfinRequestForm::RowReader
  module_function
  def get_row_by_original_key(output:, original_key:)
    matching_o = output.
      select{|h| h[:original_key] == original_key}

    if matching_o.count > 1
      flunk("something wrong, output_row contains the same record more than once")
    else
      matching_o = matching_o.first
    end

    matching_o
  end

  def get_url_by_req_id(output:, req_id:)
    matching_o = output.map{|a| {req_id: a[:req_id], req_url: a[:req_url]}}
      .select{|h| h[:req_id] == req_id}

    if matching_o.count > 1
      flunk("something wrong, output_row contains the same record more than once")
    else
      matching_o = matching_o.first
    end

    matching_o[:req_url]
  end

  # Filter any records present in output-cc-file from the list of records to process
  def filter_orig_by_output(orig:, output:)
    records_to_reject = output.
      map{|a| a[:original_key]}
      .select do |a|
      matching_o = output.select do |b|
        a == b[:original_key]
      end

      if matching_o.count > 1
        flunk("something wrong, output_row contains the same record more than once")
      else
        matching_o = matching_o.first
      end

      reject_this_one = matching_o[:req_id].present? &&
        matching_o[:ritm_id].present? &&
        matching_o[:task_id].present?
    end

    orig.reject{|b| records_to_reject.include? b[:short_description]}
  end
end

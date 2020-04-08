module EmpfinServiceReview::RowReader
  module_function
  def get_row_by_name(output:, name:)
    matching_o = output.
      select{|h| h[:name] == name}

    if matching_o.count > 1
      flunk("something wrong, output_row contains the same record more than once")
    else
      matching_o = matching_o.first
    end

    matching_o
  end

  def get_url_by_name(output:, name:)
    matching_o = output.map{|a| {name: a[:name], url: a[:url]}}
      .select{|h| h[:name] == name}

    if matching_o.count > 1
      flunk("something wrong, output_row contains the same record more than once")
    else
      matching_o = matching_o.first
    end

    matching_o[:url]
  end

  # Filter any records with no difference (matching exactly) in output-srv-file from the list of records to process
  def filter_orig_by_output(orig:, output:)
    records_to_reject = output.
      map{|a| a[:name]}
      .select do |a|
      # matching_o = output.select do |b|
      #   a == b[:name]
      # end

      # if matching_o.count > 1
      #   flunk("something wrong, output_row contains the same record more than once")
      # else
      #   matching_o = matching_o.first
      # end

      # reject_this_one = matching_o[:req_id].present? &&
      #   matching_o[:ritm_id].present? &&
      #   matching_o[:task_id].present?
    end

    flunk("not implemented yet")
    orig.reject{|b| records_to_reject.include? b[:short_description]}
  end
end

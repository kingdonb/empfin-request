module EmpfinServiceReview::Support
  def search_input
    ctx.find('input[placeholder="Search"]')
  end

  def search_for(name)
    input = search_input
    clear_search = ctx.find('a[aria-label="Remove next condition Keywords = alphasense"]')
    clear_search.click
    input.set(name)
    input.native.send_keys(:return)
  end

  def open_record(name, ctx:)
    selector = "a[aria-label=\"Open record: #{name}\"]"
    backup_selector = "a[aria-label=\"#{name[0..39]}... - Open record: #{name}\"]"
    if ctx.has_selector?(selector)
      ctx.find(selector).click
    elsif ctx.has_selector?(backup_selector)
      ctx.find(backup_selector).click
    else
      raise RecordNotFoundInBusinessAppSearch, "'#{name}' was not returned as an exact match in the search."
    end
  end

  def arrive_at_business_record(name, ctx:, output_row:)
    selector = 'input[aria-label="Name"]'
    binding.pry unless ctx.has_selector?(selector)
    name_input = ctx.find(selector)
    name_input.value == name || flunk("Business Application Name did not match after the link was clicked")
    url = URI.parse(ctx.current_url)
    output_row[:url] = url.to_s
  end

  def fetch_or_insert_output_row_from_o(o:, name:)
    output_row = EmpfinServiceReview::RowReader.get_row_by_name(output: o, name: name)

    if output_row.present?
      # we have a work in progress output row
      # binding.pry
    else
      output_row = {:name=>name,
                    :already_compared=>'no',
                    :everything_matches=>nil,
                    :alias                                  => '' ,
                    :description                            => '' ,
                    :application_url                        => '' ,
                    :support_group_service_offering_manager => '' ,
                    :supported_by                           => '' ,
                    :service_classification                 => '' ,
                    :lifecycle_status                       => '' ,
                    :"primary_support_(person)"             => '' ,
                    :"secondary_support_(person)"           => '' ,
                    :url=>""}

      # r = /^CC: (.*) - Priority: (.*) - #(\d+) (.*)$/
      # m = r.match(short_description)

      # on_behalf_of_department, priority, original_id, business_application = m[1], m[2], m[3], m[4]
      # output_row[:on_behalf_of_department] = on_behalf_of_department
      # output_row[:original_id]             = original_id
      # output_row[:business_application]    = business_application

      o << output_row
    end

    output_row
  end

  def perform_row_comparison_unless_marked_already_compared(row:, output_row:, name:, ctx:)
    unless output_row[:already_compared] == "X"
      visit_business_record_url_and_log_url_in_output(
        output_row: output_row, name: name, ctx: ctx)
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
  end

  # output should show the live "original data" from ServiceNow that differs
  # from what we have in the "orig-srv-file.csv" file
  def compare_shown_business_service_with_orig_srv_and_update_output(
    business_app_name:, ctx:, orig_row:, output_row:)

    field_mapping = {
      :name                                   => 'input[id="sys_readonly.cmdb_ci_business_app.name"]',
      :alias                                  => 'input[id="sys_readonly.cmdb_ci_business_app.u_alias"]',
      :description                            => 'textarea[id="sys_readonly.cmdb_ci_business_app.short_description"]',
      :application_url                        => 'input[id="sys_original.cmdb_ci_business_app.url"]',
      :support_group_service_offering_manager => 'input[id="cmdb_ci_business_app.support_group_label"]',
      :supported_by                           => 'input[id="cmdb_ci_business_app.supported_by_label"]',
      :service_classification                 => 'select[id="sys_readonly.cmdb_ci_business_app.u_service_classification"]',
      :lifecycle_status                       => 'select[id="sys_readonly.cmdb_ci_business_app.install_status"]',
      :"primary_support_(person)"             => 'input[id="cmdb_ci_business_app.supported_by_label"]',
      :"secondary_support_(person)"           => 'input[id="cmdb_ci_business_app.u_supported_by_secondary_label"]'
    }

    output_row[:everything_matches] = nil
    field_mapping.keys.each do |field_key|
      # (check again)
      # puts field_key

      orig_row_value = orig_row[field_key]
      # binding.pry

      if field_key == :lifecycle_status
        entry_widget = ctx.find(field_mapping[field_key], visible: false)
        code_value = entry_widget.value
        output_value = entry_widget.find("option[value=\"#{code_value}\"]").text
      else
        output_value = ctx.find(field_mapping[field_key], visible: false).value
      end
      # binding.pry
      [orig_row_value, output_value]
      # puts [orig_row_value, output_value]

      if orig_row_value == output_value
        # puts orig_row_value + "==" + output_value
        if output_row.key?(field_key)
          # clear the value in the output field if the data matches
          # (unless it's name, include that because it is the key)
          if field_key == :name
            output_row[field_key] = output_value
          else
            output_row[field_key] = '.'
          end
        else
          # do not add the key to a row when it was not present before
        end
        # binding.pry

      elsif orig_row_value.blank? && output_value.blank?
        # both are blank, no change needed
        # binding.pry

      else
        # # puts orig_row_value + "!=" + output_value
        # if output_value.present?
        #   output_row[field_key] = output_value
        # else
        #   output_row[field_key] = '[BLANK]'
        # end
        if orig_row_value.present?
          output_row[field_key] = orig_row_value
        else
          output_row[field_key] = '[BLANK IN SPREADSHEET]'
        end

        output_row[:everything_matches] = 'false'
      end
      # binding.pry
    end

  end
end

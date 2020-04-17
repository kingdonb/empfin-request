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
    if ctx.has_selector?(selector)
      ctx.find(selector).click
    else
      binding.pry
    end
  end

  def arrive_at_business_record(name, ctx:)
    selector = 'input[aria-label="Name"]'
    binding.pry unless ctx.has_selector?(selector)
    name_input = ctx.find(selector)
    name_input.value == name || flunk("Business Application Name did not match after the link was clicked")
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

    field_mapping.keys.each do |field_key|
      puts field_key

      orig_row_value = orig_row[field_key]
      if field_key == :lifecycle_status
        entry_widget = ctx.find(field_mapping[field_key], visible: false)
        code_value = entry_widget.value
        output_value = entry_widget.find("option[value=\"#{code_value}\"]").text
      else
        output_value = ctx.find(field_mapping[field_key], visible: false).value
      end

      if orig_row_value == output_value
        # puts orig_row_value + "==" + output_value
        # output_row[field_key] = ''

      elsif orig_row_value.blank? && output_value.blank?
        # both are blank, no change needed

      else
        # puts orig_row_value + "!=" + output_value
        if output_value.present?
          output_row[field_key] = output_value
        else
          output_row[field_key] = '[BLANK]'
        end

        # binding.pry
        output_row[:everything_matches] = 'false'
      end
    end
  end
end

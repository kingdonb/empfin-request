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
                    :finalized=>nil,
                    :alias                                  => '',
                    :description                            => '',
                    :application_url                        => '',
                    :sn_service_offering_manager            => '',
                    :support_group_service_offering_manager => '',
                    :supported_by                           => '',
                    :service_classification                 => '',
                    :lifecycle_status                       => '',
                    :"primary_support_(person)"             => '',
                    :"secondary_support_(person)"           => '',
                    :url                                    => '',
                    :requesturl                             => ''
      }

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

  def visit_business_record_url_and_log_url_in_output(output_row:, name:, ctx:)
    if output_row[:url].present?
      ctx.visit(output_row[:url])
    else
      login_handle.visit_request_url(ctx: ctx)
      # methods defined in Support module:
      search_for(name)
      open_record(name, ctx: ctx)
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
      :sn_service_offering_manager            => 'input[id="cmdb_ci_business_app.owned_by_label"]',
      :support_group_service_offering_manager => 'input[id="cmdb_ci_business_app.support_group_label"]',
      :supported_by                           => 'input[id="cmdb_ci_business_app.u_business_owner_label"]',
      :service_classification                 => 'select[id="sys_readonly.cmdb_ci_business_app.u_service_classification"]',
      :lifecycle_status                       => 'select[id="sys_readonly.cmdb_ci_business_app.install_status"]',
      :guidance_council                       => 'select[id="sys_readonly.cmdb_ci_business_app.u_guidance_council"]',
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

      elsif field_key == :sn_service_offering_manager
        output_row[field_key] = output_value
      elsif field_key == :supported_by && output_value.present?
        # do not overwrite "business owner" with "supported by" if it is already present here
    #    binding.pry
        output_row[field_key] = '.'

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
    #      binding.pry
          output_row[:everything_matches] = 'false'
        else
          output_row[field_key] = '[BLANK]'
        end
      end
      # binding.pry
    end
  end

  def perform_record_update_from_output_row_if_needed(
    row:, output_row:, name:, ctx:)

    already_compared = output_row[:already_compared]
    everything_matches = output_row[:everything_matches]
    finalized = output_row[:finalized]

    unless finalized == "X"
      if already_compared == "X" and everything_matches == "false"
        ctx.visit(EmpfinServiceReview::SERVICENOW_REQUEST_FORM_URL)
        ctx.find('select[id="IO:f565ec151b2fb740c81c64207e4bcbea"]').
          select('Update all fields')

        # Business Application Name
        input = ctx.find('input[id="sys_display.IO:69f4e0151b2fb740c81c64207e4bcb83"]')
        input.set(name)
        input.native.send_keys(:return)

        # Reason for Change
        input = ctx.find('textarea[id="IO:a9f4e0151b2fb740c81c64207e4bcbb8"]')
        input.set('Finance Service Review')

        # fields that we have in our output file list (may have changed)
        # output_fields = %i[alias description application_url
        #   support_group_service_offering_manager
        #   supported_by service_classification lifecycle_status
        #   primary_support_(person) secondary_support_(person)]

        # fields that are on the request page, with a proposed value alongside original value
        page_fields = { # ['to_field', 'from_field']
          :name                       => ['input[id="IO:743cb9911be3f740c81c64207e4bcb54"]',
                                          'input[id="IO:49cc7d111be3f740c81c64207e4bcb8a"]'],
          :alias                      => ['input[id="IO:477c7d111be3f740c81c64207e4bcbcb"]',
                                          'input[id="IO:d1f4e0151b2fb740c81c64207e4bcb5c"]'],
          :description                => ['textarea[id="IO:33b17e651ba73b40c81c64207e4bcb55"]',
                                          'textarea[id="IO:4d027e251ba73b40c81c64207e4bcbe8"]'],
          :service_classification     => ['select[id="IO:adf4e0151b2fb740c81c64207e4bcbe6"]',
                                          'input[id="IO:e5f4e0151b2fb740c81c64207e4bcbdb"]'],

          # "Service Offering Manager" - Business Owner
          :supported_by               => ['input[id="sys_display.IO:152df85a1b2fbb40c81c64207e4bcbdf"]',
                                          'input[id="sys_display.IO:da8dbc9a1b2fbb40c81c64207e4bcb93"]'],

          # "Supported By" - Primary Support Person
          :"primary_support_(person)" => ['input[id="sys_display.IO:0c34aaa51b673b40c81c64207e4bcb6e"]',
                                          'input[id="sys_display.IO:e9f4e0151b2fb740c81c64207e4bcb95"]'],

        :"secondary_support_(person)" => ['input[id="sys_display.IO:3ffd745a1b2fbb40c81c64207e4bcb8c"]',
                                          'input[id="sys_display.IO:714efcda1b2fbb40c81c64207e4bcb5c"]'],
:support_group_service_offering_manager => ['input[id="sys_display.IO:422f23351b40c4d0c81c64207e4bcb7a"]',
                                            'input[id="sys_display.IO:1b6f67351b40c4d0c81c64207e4bcb22"]'],
          :operational_status         => ['select[id="IO:25f4e0151b2fb740c81c64207e4bcbc9"]',
                                          'select[id="IO:19f4e0151b2fb740c81c64207e4bcb78"]'],
          :lifecycle_status           => ['select[id="IO:4ce7c25e1b49c490c81c64207e4bcb7b"]',
                                          'select[id="IO:3418425e1b49c490c81c64207e4bcb47"]'],
          :install_type               => ['select[id="IO:ddf4e0151b2fb740c81c64207e4bcb72"]',
                                          'input[id="IO:31f4e0151b2fb740c81c64207e4bcbf9"]'],
          :application_type           => ['select[id="IO:791845ba1bf3fb80c81c64207e4bcb61"]',
                                          'input[id="IO:29690d3e1bf3fb80c81c64207e4bcb1f"]'],
          :application_url            => ['input[id="IO:5eecca2e1b4848d0c81c64207e4bcb5d"]',
                                          'input[id="IO:354c422e1b4848d0c81c64207e4bcbc4"]'],
          :application_platform       => ['input[id="sys_display.IO:130dce2e1b4848d0c81c64207e4bcb5a"]',
                                          'input[id="sys_display.IO:6e7cc22e1b4848d0c81c64207e4bcbe1"]'],
          :is_platform                => ['select[id="IO:bd3dc26e1b4848d0c81c64207e4bcbe6"]',
                                          'input[id="IO:9d9c462a1b4848d0c81c64207e4bcb58"]'],
          :infosec_approval           => ['select[id="IO:f15dca2e1b4848d0c81c64207e4bcb90"]',
                                          'input[id="IO:46ccca2e1b4848d0c81c64207e4bcb44"]'],
          :sla_level                  => ['select[id="IO:90d58d761bf3fb80c81c64207e4bcbd0"]',
                                          'input[id="IO:5c574d761bf3fb80c81c64207e4bcb7f"]'],
          :user_base                  => ['select[id="IO:daa949fa1bf3fb80c81c64207e4bcb8e"]',
                                          'input[id="IO:e81a017e1bf3fb80c81c64207e4bcb9c"]'],
          :guidance_council           => ['select[id="IO:5a9ac53e1bf3fb80c81c64207e4bcb21"]',
                                          'input[id="IO:7e6a457e1bf3fb80c81c64207e4bcbcf"]']
        }

        page_fields.each do |field_label, to_from_selectors|
          to_selector   = to_from_selectors[0]
          from_selector = to_from_selectors[1]
          to_field      = ctx.find(to_selector)
          from_field    = ctx.find(from_selector)
          output_value  = output_row[field_label]

          if field_label == :name
            # Make sure the record data has all loaded with "Application Name"
            ctx.find_field('Original Name', readonly: true, with: output_value)
          end

          if output_value.present?
            if (from_field.value == output_value || output_value == '.') \
              || output_value == '[BLANK]' && from_field.present?
              # they matched or we forgot to fill out the value in our orig-srv
              # so, set to_field with value of from_field to keep it the same.
              #(ed): no, do not fill out anything in "proposed" where the data is blank
              # set_by_selector(
              #   selector: to_selector, set_value: from_field.value, field_to_set: to_field)
            elsif (from_field.value.present? && field_label == :supported_by)
              # do not overwrite existing value in "Business Owner" field
            elsif output_value.present?
              set_by_selector(
                selector: to_selector, set_value: output_value, field_to_set: to_field)
            else
              set_by_selector(
                selector: to_selector, set_value: output_value, field_to_set: to_field)
              # set to_field with value of output_value
            end
          else
            # # Did not find a diff in this column in orig srv spreadsheet file, (so echo it forward)
            # (ed: no, do not echo it forward, only fill out data that is missing or differs)
            # set_by_selector(
            #   selector: to_selector, set_value: from_field.value, field_to_set: to_field)
          end
        end

        if ctx.has_selector?('div.fieldmsg.notification.notification-error', text: "Invalid reference")
          ctx.find('div.fieldmsg.notification.notification-error', text: "Invalid reference")
          binding.pry
        end

        ctx.find('button', text: 'Submit').click

        unless ctx.has_selector?('a#requesturl')
          binding.pry
        end
        output_row[:requesturl] = ctx.find('a#requesturl')[:href]
      end
    end
  end

  def set_by_selector(selector:, set_value:, field_to_set:)
    if /^select/.match(selector)
      option_to_set_selector = "option[value=\"#{set_value}\"]"
      if field_to_set.has_selector?(option_to_set_selector)
        field_to_set.find(option_to_set_selector).select_option
      else
        field_to_set.select(set_value)
      end
    else
      field_to_set.set(set_value)
    end
  rescue Capybara::ElementNotFound => e
    binding.pry
  end
end

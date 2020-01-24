module EmpfinRequestForm
  #EMPFIN_REQUEST_URL = 'https://nd.service-now.com/com.glideapp.servicecatalog_cat_item_view.do?v=1&sysparm_id=9f4426e6db403200de73f5161d96198d'
  EMPFIN_REQUEST_URL = 'https://ndtest.service-now.com/com.glideapp.servicecatalog_cat_item_view.do?v=1&sysparm_id=9f4426e6db403200de73f5161d96198d'

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

  require "csv"
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

  module_function :filter_orig_by_output, :to_csv, :get_url_by_req_id, :get_row_by_original_key

  class Login
    USERNAME_PASSWORD_BASE64 = ENV.fetch('USERNAME_PASSWORD_BASE64')
    USERNAME_PASSWORD = Base64.decode64(USERNAME_PASSWORD_BASE64)
    USERNAME = USERNAME_PASSWORD.split(':')[0]
    PASSWORD = USERNAME_PASSWORD.split(':')[1]

    def initialize(username: USERNAME, password: PASSWORD, ctx:)
      #ctx.visit 'https://sn.nd.edu'
      ctx.visit 'https://ndtest.service-now.com'
      ctx.find('#okta-signin-username').set(USERNAME)
      ctx.find('#okta-signin-password').set(PASSWORD)

      ctx.find('div.navbar-header', text: "ServiceNow Home Page\nTEST", wait: 30)
      #ctx.find('div.navbar-header',
      #         text: 'Service Management', wait: 100)
      visit_request_url(ctx: ctx)
    end

    def visit_request_url(ctx:)
      ctx.visit EMPFIN_REQUEST_URL
    end
  end

  class Fillout
    GROUP_ENTRY =
      'input[id="sys_display.IO:4e621036db043200de73f5161d96196b"]'
    DESCRIBE_WHAT_WORK =
      'textarea[id="IO:96252ee6db403200de73f5161d9619c4"]'
    ASSIGN_USER =
      'input[id="sys_display.IO:e756cc171b3df7009a56ea866e4bcb49"]'
    IS_ON_BEHALF_OF =
      'select[id="IO:d5bbaa0a0ff4d240a6c322d8b1050e1e"]'
    ON_BEHALF_OF_WHOM =
      'input[id="sys_display.IO:23cb6a0a0ff4d240a6c322d8b1050e2d"]'
    TASK_SHORT_DESCRIPTION =
      'input[id="sc_task.short_description"]'
    TASK_DESCRIPTION =
      'textarea[id="activity-stream-textarea"]'
    TASK_BUSINESS_SERVICE =
      'input[id="sys_display.sc_task.business_service"]'
    TASK_STATE =
      'select[id="sc_task.state"]'
      # # due_date: row[:due_date],
    attr_reader :ctx, :iframe

    def initialize(ctx:, iframe:)
      @ctx = ctx; @iframe = iframe
      #ctx.within_frame(iframe) do
        ctx.find('#item_table')
        ctx.find('table td.guide_tray', text: 'Customer Care Request')
      #end
    end

    def fill_out_1_with_row(row)
      fill_out_1(
        work: row[:short_description],
        group: row[:group],
        user: row[:assigned_to],
        request_on_behalf_of: row[:behalf_of],
      )
    end

    def fill_out_2_with_row(row)
      fill_out_2(
        task_short_description: row[:short_description],
        description: row[:long_description],
        work_notes: row[:work_note],
        business_service: row[:bus_service],
        business_application_impacted: row[:bus_service],
        priority_order: row[:more_info],
        state: row[:state],
        what_oit_resources_needed: row[:oit_resources],
        # due_date: row[:due_date],
        what_do_i_estimate_my_effort_hrs: row[:time_estimate],
        what_do_i_expect_to_be_delivered: row[:deliverables],
      )
    end

    def fill_out_1(work:, group:, user:, request_on_behalf_of:)
      describe_what_work(work)
      group_entry(group)
      assign_user(user)
      yes_on_behalf_of(request_on_behalf_of)
    end

    def fill_out_2(task_short_description:, description:, work_notes:, business_service:,
                   business_application_impacted:, priority_order:, state:,
                   what_oit_resources_needed:,
                   what_do_i_estimate_my_effort_hrs:, what_do_i_expect_to_be_delivered:)
      ctx.find(TASK_SHORT_DESCRIPTION).set(task_short_description)
      ctx.find(TASK_DESCRIPTION).set(description)

      ctx.find(TASK_BUSINESS_SERVICE).set(business_service)

      unless ctx.all('tr td.ac_cell:not(.ac_additional):not(.ac_additional_repeat)', text: business_service).count == 1
        puts "Business Service: #{business_service}"
        # Please click the business service
        binding.pry
      else
        ctx.find('tr td.ac_cell:not(.ac_additional):not(.ac_additional_repeat)', text: business_service).click
      end

      ctx.find('span.sn-tooltip-basic', text: 'What Business Application is impacted?').
        find(:xpath, "./ancestor::div[contains(concat(' ', @class, ' '), ' form-group ')][1]").
        find('input').set(business_application_impacted)
      unless ctx.all('tr td.ac_cell:not(.ac_additional):not(.ac_additional_repeat)',
          text: business_application_impacted).count == 1
        puts "Business Application Impacted: #{business_application_impacted}"
        # Please click the business application impacted
        binding.pry
      else
        ctx.find('tr td.ac_cell:not(.ac_additional):not(.ac_additional_repeat)',
                 text: business_application_impacted).click
      end

      ctx.find('span.sn-tooltip-basic', text: 'Priority Order').
        find(:xpath, "./ancestor::div[contains(concat(' ', @class, ' '), ' form-group ')][1]").
        find('input').set(priority_order)
      ctx.find('span.sn-tooltip-basic', text: 'What OIT resources are needed to handle this request?').
        find(:xpath, "./ancestor::div[contains(concat(' ', @class, ' '), ' form-group ')][1]").
        find('textarea').set(what_oit_resources_needed)
      ctx.find('span.sn-tooltip-basic', text: "What do I estimate my or my team's effort (hrs) needed to perform this request?").
        find(:xpath, "./ancestor::div[contains(concat(' ', @class, ' '), ' form-group ')][1]").
        find('input').set(what_do_i_estimate_my_effort_hrs)
      ctx.find('span.sn-tooltip-basic', text: 'What do you expect to be delivered at the completion of this request?').
        find(:xpath, "./ancestor::div[contains(concat(' ', @class, ' '), ' form-group ')][1]").
        find('textarea').set(what_do_i_expect_to_be_delivered)
      ctx.find(TASK_STATE).select(state)
    end

    def submit_1
      request_no = nil
      #ctx.within_frame(iframe) do
        order_now = ctx.find('button#oi_order_now_button')
        # binding.pry
        order_now.click
        ctx.find('span',
                 text: 'Thank you, your request has been submitted')
        request_link = ctx.find('a#requesturl')
        request_no = request_link.text
      #end

      return request_no
    end

    def submit_2
      ctx.all('button', text: 'Update').first.click
      # binding.pry
    end

    def follow_req_link(req_no)
      request_link = ctx.find('a#requesturl', text: req_no)
      req_link_url = request_link[:href]
      request_link.click
      return req_link_url
    end

    def find_ritm_number
      tab = ctx.find('span.tab_caption_text', text: 'Requested Items')
      link = ctx.find('a.linked.formlink', text: 'RITM00')
      text = link.text
      return link, text
    end

    def find_task_number
      tab = ctx.find('span.tab_caption_text', text: 'Catalog Tasks')
      link = ctx.find('a.linked.formlink', text: 'TASK00')
      text = link.text
      return link, text
    end

    # short description - needs to be munged later
    def describe_what_work(val)
      #ctx.within_frame(iframe) do
        ctx.find(DESCRIBE_WHAT_WORK).set(val)
      #end
    end
    def group_entry(val)
      #ctx.within_frame(iframe) do
        ctx.find(GROUP_ENTRY).set(val)

        unless ctx.all('span', text: val).count == 1
          puts "Group to assign to: #{val}"
          # Please click the group to assign
          binding.pry
        else
          ctx.find('span', text: val).click
        end
      #end
    end
    def assign_user(val)
      #ctx.within_frame(iframe) do
        ctx.find(ASSIGN_USER).set(val)

        unless ctx.all('tr td.ac_cell:not(.ac_additional):not(.ac_additional_repeat)',
            text: val).count == 1
          puts "User to assign to: #{val}"
          # Please click the user to assign
          binding.pry
        else
          ctx.find('tr td.ac_cell:not(.ac_additional):not(.ac_additional_repeat)',
                   text: val).click
        end
      #end
    end

    def yes_on_behalf_of(val)
      ctx.find(IS_ON_BEHALF_OF).select('Yes')
      ctx.find(ON_BEHALF_OF_WHOM).set(val)

      unless ctx.all('tr td.ac_cell:not(.ac_additional):not(.ac_additional_repeat)',
          text: val).count == 1
        puts "Submitted on behalf of: #{val}"
        # Please click the user submitted on behalf of
        binding.pry
      else
        ctx.find('tr td.ac_cell:not(.ac_additional):not(.ac_additional_repeat)',
                 text: val).click
      end
    end
  end
end

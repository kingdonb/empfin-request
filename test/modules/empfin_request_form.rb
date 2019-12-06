module EmpfinRequestForm
  #EMPFIN_REQUEST_URL = 'https://nd.service-now.com/com.glideapp.servicecatalog_cat_item_view.do?v=1&sysparm_id=9f4426e6db403200de73f5161d96198d'
  EMPFIN_REQUEST_URL = 'https://ndtest.service-now.com/com.glideapp.servicecatalog_cat_item_view.do?v=1&sysparm_id=9f4426e6db403200de73f5161d96198d'

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

      ctx.find('div.navbar-header',
               text: 'Service Management', wait: 100)
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
      # TODO
      binding.pry
    end

    def submit
      request_no = nil
      #ctx.within_frame(iframe) do
        order_now = ctx.find('button#oi_order_now_button')
        #KB pending - do not automate this until we have consensus
        # order_now.click
        binding.pry
        ctx.find('span',
                 text: 'Thank you, your request has been submitted')
        request_link = ctx.find('a#requesturl')
        request_no = request_link.text
      #end

      return request_no
    end

    def follow_req_link(req_no)
      request_link = ctx.find('a#requesturl', text: req_no)
      request_link.click
    end

    def find_ritm_number
      tab = ctx.find('span.tab_caption_text', text: 'Requested Items')
      link = ctx.find('a.linked.formlink', text: 'RITM00')
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
      #end
    end
    def assign_user(val)
      #ctx.within_frame(iframe) do
        ctx.find(ASSIGN_USER).set(val)
      #end
    end

    def yes_on_behalf_of(val)
      ctx.find(IS_ON_BEHALF_OF).select('Yes')
      ctx.find(ON_BEHALF_OF_WHOM).set(val)
    end
  end
end

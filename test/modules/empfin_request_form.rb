module EmpfinRequestForm
  EMPFIN_REQUEST_URL = 'https://nd.service-now.com/nav_to.do?uri=%2Fcom.glideapp.servicecatalog_cat_item_view.do%3Fv%3D1%26sysparm_id%3D9f4426e6db403200de73f5161d96198d'

  class Login
    USERNAME_PASSWORD_BASE64 = ENV.fetch('USERNAME_PASSWORD_BASE64')
    USERNAME_PASSWORD = Base64.decode64(USERNAME_PASSWORD_BASE64)
    USERNAME = USERNAME_PASSWORD.split(':')[0]
    PASSWORD = USERNAME_PASSWORD.split(':')[1]

    def initialize(username: USERNAME, password: PASSWORD, ctx:)
      ctx.visit 'https://sn.nd.edu'
      ctx.find('#okta-signin-username').set(USERNAME)
      ctx.find('#okta-signin-password').set(PASSWORD)

      ctx.find('div.navbar-header',
               text: 'Service Management', wait: 10)
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
    attr_reader :ctx, :iframe

    def initialize(ctx:, iframe:)
      @ctx = ctx; @iframe = iframe
      ctx.within_frame(iframe) do
        ctx.find('#item_table')
        ctx.find('table td.guide_tray', text: 'Customer Care Request')
      end
    end

    def fill_out(work:, group:, user:)
      describe_what_work.value(work)
      group_entry.value(group)
      assign_user.value(user)
    end

    def submit
      order_now = ctx.find('button#oi_order_now_button')
      #KB pending - do not automate this until we have consensus
      # order_now.click
      binding.pry
      ctx.find('span',
               text: 'Thank you, your request has been submitted')
      request_link = ctx.find('a#requesturl')
      request_no = request_link.text
    end

    def describe_what_work
      ctx.find(DESCRIBE_WHAT_WORK)
    end
    def group_entry
      ctx.find(GROUP_ENTRY)
    end
    def assign_user
      ctx.find(ASSIGN_USER)
    end
  end
end

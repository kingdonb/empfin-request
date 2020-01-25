module EmpfinRequestForm
  class Login
    LOGIN_DATA = ENV.fetch('USERNAME_PASSWORD_BASE64')

    def initialize(login_data: LOGIN_DATA, ctx:)
      @login_config = LoginConfig.new(login_data)

      okta_heavy_lifting(ctx: ctx)
      visit_request_url(ctx: ctx)
    end

    private
    attr_accessor :login_config

    def okta_heavy_lifting(ctx:)
      #ctx.visit 'https://sn.nd.edu'
      ctx.visit 'https://ndtest.service-now.com'
      ctx.find('#okta-signin-username').set(username)
      ctx.find('#okta-signin-password').set(password)

      ctx.find('div.navbar-header', text: "ServiceNow Home Page\nTEST", wait: 30)
      #ctx.find('div.navbar-header',
      #         text: 'Service Management', wait: 100)
    end

    def visit_request_url(ctx:)
      ctx.visit EmpfinRequestForm::EMPFIN_REQUEST_URL
    end

    delegate :username, :password, to: :login_config
  end
end

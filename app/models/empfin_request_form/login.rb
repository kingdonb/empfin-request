module EmpfinRequestForm
  class Login
    LOGIN_DATA = ENV.fetch('USERNAME_PASSWORD_BASE64')

    def initialize(login_data: LOGIN_DATA, ctx:)
      @login_config = LoginConfig.new(login_data)

      okta_heavy_lifting(ctx: ctx)
      visit_request_url(ctx: ctx)
    end

    def visit_request_url(ctx:)
      ctx.visit EmpfinRequestForm::EMPFIN_REQUEST_URL
    end

    private
    attr_accessor :login_config

    def okta_heavy_lifting(ctx:)
      #ctx.visit 'https://sn.nd.edu'
      #ctx.visit 'https://ndtest.service-now.com'
      ctx.visit EmpfinRequestForm::SERVICENOW_SITE_URL
      ctx.find('#okta-signin-username').set(username)
      ctx.find('#okta-signin-password').set(password)

      ctx.find('div.navbar-header',
               text: EmpfinRequestForm::SERVICENOW_HOME_PAGE_STRING, wait: 30)
    end

    delegate :username, :password, to: :login_config
  end
end

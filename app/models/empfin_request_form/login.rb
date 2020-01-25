module EmpfinRequestForm
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
end

module EmpfinRequestForm
  EMPFIN_REQUEST_URL = 'https://nd.service-now.com/nav_to.do?uri=%2Fcom.glideapp.servicecatalog_cat_item_view.do%3Fv%3D1%26sysparm_id%3D9f4426e6db403200de73f5161d96198d'

  class Login
    USERNAME_PASSWORD_BASE64 = ENV.fetch('USERNAME_PASSWORD_BASE64')
    USERNAME_PASSWORD = Base64.decode64(USERNAME_PASSWORD_BASE64)
    USERNAME = USERNAME_PASSWORD.split(':')[0]
    PASSWORD = USERNAME_PASSWORD.split(':')[1]

    def initialize(username: USERNAME, password: PASSWORD, context:)
      context.visit 'https://sn.nd.edu'
      context.find('#okta-signin-username').set(USERNAME)
      context.find('#okta-signin-password').set(PASSWORD)

      context.find('div.navbar-header', text: 'Service Management', wait: 10)
      context.visit EMPFIN_REQUEST_URL
    end
  end
end

module EmpfinServiceReview::Constants
  # Production:
  # EMPFIN_REQUEST_URL = 'https://nd.service-now.com/'\
  #   'cmdb_ci_business_app_list.do?sysparm_query=123TEXTQUERY321'\
  #   '%3Dalphasense%5Eoperational_statusIN1%2C2'.freeze
  # SERVICENOW_SITE_URL = 'https://sn.nd.edu'.freeze
  # SERVICENOW_HOME_PAGE_STRING = "Service Management".freeze

  # Test:
  EMPFIN_REQUEST_URL = 'https://ndtest.service-now.com/'\
    'cmdb_ci_business_app_list.do?sysparm_query=123TEXTQUERY321'\
    '%3Dalphasense%5Eoperational_statusIN1%2C2'.freeze
  SERVICENOW_SITE_URL = 'https://ndtest.service-now.com'.freeze
  SERVICENOW_HOME_PAGE_STRING = "ServiceNow Home Page\nTEST".freeze
end

module EmpfinRequestForm::Constants
  # Production:
  #EMPFIN_REQUEST_URL = 'https://nd.service-now.com/'\
  #  'com.glideapp.servicecatalog_cat_item_view.do'\
  #  '?v=1&sysparm_id=9f4426e6db403200de73f5161d96198d'.freeze
  #SERVICENOW_SITE_URL = 'https://sn.nd.edu'.freeze
  #SERVICENOW_HOME_PAGE_STRING = "Service Management".freeze

  # Test:
  EMPFIN_REQUEST_URL = 'https://ndtest.service-now.com/'\
    'com.glideapp.servicecatalog_cat_item_view.do'\
    '?v=1&sysparm_id=9f4426e6db403200de73f5161d96198d'.freeze
  SERVICENOW_SITE_URL = 'https://ndtest.service-now.com'.freeze
  SERVICENOW_HOME_PAGE_STRING = "ServiceNow Home Page\nTEST".freeze
end

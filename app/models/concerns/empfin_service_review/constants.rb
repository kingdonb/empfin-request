module EmpfinServiceReview::Constants
  # Production:
  EMPFIN_REQUEST_URL = 'https://nd.service-now.com/'\
    'cmdb_ci_business_app_list.do?sysparm_query=123TEXTQUERY321'\
    '%3Dalphasense%5Eoperational_statusIN1%2C2'.freeze
  SERVICENOW_SITE_URL = 'https://sn.nd.edu'.freeze
  SERVICENOW_HOME_PAGE_STRING = "Service Management".freeze
  SERVICENOW_REQUEST_FORM_URL = 'https://nd.service-now.com/'\
    'com.glideapp.servicecatalog_cat_item_view.do?v=1&sysparm_id=91f464d11b2fb740c81c64207e4bcbcc'\
    '&sysparm_link_parent=6f417e690f632240a6c322d8b1050e8f'\
    '&sysparm_catalog=742ce428d7211100f2d224837e61036d'\
    '&sysparm_catalog_view=catalog_technical_catalog&sysparm_view=catalog_technical_catalog'.freeze

  # Test:
  # EMPFIN_REQUEST_URL = 'https://ndtest.service-now.com/'\
  #   'cmdb_ci_business_app_list.do?sysparm_query=123TEXTQUERY321'\
  #   '%3Dalphasense%5Eoperational_statusIN1%2C2'.freeze
  # SERVICENOW_SITE_URL = 'https://ndtest.service-now.com'.freeze
  # SERVICENOW_HOME_PAGE_STRING = "ServiceNow Home Page\nTEST".freeze
  # SERVICENOW_REQUEST_FORM_URL = 'https://ndtest.service-now.com/'\
  #   'com.glideapp.servicecatalog_cat_item_view.do?v=1&sysparm_id=91f464d11b2fb740c81c64207e4bcbcc'\
  #   '&sysparm_link_parent=6f417e690f632240a6c322d8b1050e8f'\
  #   '&sysparm_catalog=742ce428d7211100f2d224837e61036d'\
  #   '&sysparm_catalog_view=catalog_technical_catalog&sysparm_view=catalog_technical_catalog'.freeze
end

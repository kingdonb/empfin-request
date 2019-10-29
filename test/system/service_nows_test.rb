require "application_system_test_case"

class ServiceNowsTest < ApplicationSystemTestCase
  # test "visiting the index" do
  #   visit service_nows_url
  #
  #   assert_selector "h1", text: "ServiceNow"
  # end

  # adapted from:
  # https://medium.com/@tjdracz/interactive-debug-sessions-in-rspec-with-capybara-6c4dec2619d3
  # https://stackoverflow.com/questions/6807268/rails-port-of-testing-environment
  # https://www.rubydoc.info/github/jnicklas/capybara/Capybara%2FSession:visit
  # [X] https://stackoverflow.com/a/8332872/661659
  def interactive_debug_session(log_in_as = nil)
    # return unless Capybara.current_driver == Capybara.javascript_driver
    # return unless current_url
    # login_as(log_in_as, scope: :user) if log_in_as.present?
    # Launchy.open(current_url)
    binding.pry
  end

  EMPFIN_REQUEST_URL = 'https://nd.service-now.com/nav_to.do?uri=%2Fcom.glideapp.servicecatalog_cat_item_view.do%3Fv%3D1%26sysparm_id%3D9f4426e6db403200de73f5161d96198d'

  test 'something' do

    visit 'https://sn.nd.edu'
    interactive_debug_session


  end
end

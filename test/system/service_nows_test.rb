require "application_system_test_case"
require "modules/empfin_request_form"

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


  test 'something' do
    EmpfinRequestForm::Login.new(context: self)

    ifr = find('main iframe#gsft_main', wait: 10)
    within_frame(ifr) do
      find('#item_table')
      find('table td.guide_tray', text: 'Customer Care Request')
      group_entry = find('input[id="sys_display.IO:4e621036db043200de73f5161d96196b"]')
      describe_what_work = find('textarea[id="IO:96252ee6db403200de73f5161d9619c4"]')
      assign_user = find('input[id="sys_display.IO:e756cc171b3df7009a56ea866e4bcb49"]')

      describe_what_work.set(
        'KB - This is a Test - Test of long text description - Please perform the following steps (test) Test - KB - TEST ONLY'
      )
      group_entry.set(
        'Employee Finance Solutions'
      )
      assign_user.set(
        'Kingdon Barrett'
      )
      order_now = find('button#oi_order_now_button')
      #KB pending - do not automate this until we have consensus
      # order_now.click
      binding.pry
      find('span', text: 'Thank you, your request has been submitted')
      request_no = find('a#requesturl').text

    end

    # interactive_debug_session
  end
end

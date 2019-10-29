ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  # parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # fixtures :all

  Capybara.app_host = 'https://sn.nd.edu'
  Capybara.run_server = false # don't start Rack

  # Add more helper methods to be used by all tests here...
end

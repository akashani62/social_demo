ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module SessionTestHelper
  FIXTURE_USER_PASSWORD = "password123"

  def sign_in_as(user)
    post sign_in_url, params: { session: { email: user.email, password: FIXTURE_USER_PASSWORD } }
  end
end

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in *.yml in test/fixtures for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

class ActionDispatch::IntegrationTest
  include SessionTestHelper
end

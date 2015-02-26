require 'holo'
require 'holo/wm'

Dir['spec/support/**/*.rb'].map { |e| require e.gsub 'spec/', '' }

RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    mocks.verify_doubled_constant_names = true
    mocks.verify_partial_doubles = true
  end
end

if ENV['COVERAGE']
  require 'codeclimate-test-reporter'
  SimpleCov.start do
    add_filter '/spec/'
    add_group 'Core', ['lib', 'lib/api_cached_attributes']
    add_group 'Storage', 'lib/api_cached_attributes/storage'
    add_group 'Lookup', 'lib/api_cached_attributes/lookup'
  end
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'api_cached_attributes'

require 'pry'

Dir.glob('./spec/support/**/*.rb').each { |f| require f }

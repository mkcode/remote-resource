if ENV['COVERAGE']
  require 'codeclimate-test-reporter'
  require 'simplecov-console'
  SimpleCov.start do
    add_filter '/spec/'
    add_group 'Core', [*Dir.glob('lib/*.rb'),
                       *Dir.glob('lib/api_cached_attributes/*.rb'),
                       'lib/api_cached_attributes/configuration']
    add_group 'Storage', 'lib/api_cached_attributes/storage/*'
    add_group 'Lookup', 'lib/api_cached_attributes/lookup/*'
    if ENV['CI']
      formatter SimpleCov::Formatter::MultiFormatter[
        CodeClimate::TestReporter::Formatter,
        SimpleCov::Formatter::Console
      ]
    else
      formatter SimpleCov::Formatter::MultiFormatter[
        SimpleCov::Formatter::HTMLFormatter,
        SimpleCov::Formatter::Console
      ]
    end
  end
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'api_cached_attributes'
require 'api_cached_attributes/storage/redis'

require 'pry'

Dir.glob('./spec/support/**/*.rb').each { |f| require f }

RSpec.configure do |config|
  config.include ClassHelpers
  config.include ClientHelpers
end

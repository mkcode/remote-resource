if ENV['COVERAGE']
  require 'codeclimate-test-reporter'
  require 'simplecov-console'
  SimpleCov.start do
    add_filter '/spec/'
    add_group 'Core', [*Dir.glob('lib/*.rb'),
                       *Dir.glob('lib/remote_resource/*.rb'),
                       'lib/remote_resource/configuration']
    add_group 'Storage', 'lib/remote_resource/storage/*'
    add_group 'Lookup', 'lib/remote_resource/lookup/*'
    if ENV['CI']
      formatter SimpleCov::Formatter::MultiFormatter.new [
        CodeClimate::TestReporter::Formatter,
        SimpleCov::Formatter::Console
      ]
    else
      formatter SimpleCov::Formatter::MultiFormatter.new [
        SimpleCov::Formatter::HTMLFormatter,
        SimpleCov::Formatter::Console
      ]
    end
  end
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'remote_resource'
require 'remote_resource/storage/redis'

require 'pry'

Dir.glob('./spec/support/**/*.rb').each { |f| require f }

RSpec.configure do |config|
  config.include ClassHelpers
  config.include ClientHelpers
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'api_cached_attributes'

require 'pry'

Dir.glob('./spec/support/**/*.rb').each { |f| require f }

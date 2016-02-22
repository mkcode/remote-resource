require_relative './evaluator'

module ApiCachedAttributes
  # Our humble lookup service
  class LookupService
    attr_reader :key_prefix

    def initialize(base_class, options)
      @base_class = base_class
      @options = options
      @evaluator = Evaluator.new(base_class)
    end

    def get(method, named_response = :default)
      # key = key_for(method, named_response)
      response = @evaluator.response(named_response)
      response.send(method.to_sym)
    end

    def key_prefix
      @base_class.underscore
    end

    def key_for(method, named_response = :default)
      "#{@key_prefix}/#{named_response}-method"
    end
  end
end

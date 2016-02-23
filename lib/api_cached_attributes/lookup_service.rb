require_relative './evaluator'

module ApiCachedAttributes
  # Our humble lookup service
  class LookupService
    attr_reader :key_prefix

    def initialize(base_class, options)
      @base_class = base_class
      @options = options
      @evaluator = Evaluator.new(@base_class, @options)
    end

    def get(method, scope, named_resource = :default)
      # key = key_for(method, named_resource)
      @evaluator.client_scope = scope
      resource = @evaluator.resource(named_resource)
      resource.send(method.to_sym)
    end

    def key_prefix
      @base_class.underscore
    end

    def key_for(method, named_resource = :default)
      "#{@key_prefix}/#{named_resource}-method"
    end
  end
end

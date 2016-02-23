require_relative './evaluator'
require_relative './db_cache'

module ApiCachedAttributes
  # Our humble lookup service
  class AttributeMethodResolver
    attr_reader :key_prefix
    attr_accessor :evaluator, :db_cache

    def initialize(base_class, options)
      @base_class = base_class
      @options = options
      @evaluator = nil
      @db_cache = nil
    end

    def get(method, scope, named_resource = :default, target_instance)
      key = key_for(method, scope, named_resource)
      binding.pry
      @evaluator.client_scope = scope
      resource = @evaluator.resource(named_resource)
      resource.send(method.to_sym)
    end

    def key_prefix
      @base_class.underscore
    end

    def key_for(method, scope, named_resource = :default)
      scope_part = scope.map{ |k,v| "#{k}=#{v}" }.join('&')
      # "#{@key_prefix}/#{scope_part}/#{named_resource}/#{method}"
      [key_prefix, scope_part, named_resource, method].join('/')
    end
  end
end

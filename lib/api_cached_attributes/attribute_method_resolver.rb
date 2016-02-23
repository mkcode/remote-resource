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
      @db_cache.target_instance = target_instance
      value = @db_cache.read_key(key)
      if value
        puts 'DB HIT'
        return value
      end
      puts 'DB MISS'
      @evaluator.client_scope = scope
      resource = @evaluator.resource(named_resource)
      value = resource.send(method.to_sym)
      @db_cache.write_key(key, value)
      value
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

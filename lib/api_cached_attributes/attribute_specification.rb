require_relative './attribute_key'

module ApiCachedAttributes
  # A value object representing an attribute defined in
  # ApiCachedAttributes::Base. An AttributeSpecification contains the
  # attributes' method name, its resource, and its API client that is used for
  # lookup. It also calculates its `key` which is used to lookup its value in
  # storage.
  class AttributeSpecification
    attr_reader :name, :base_class
    attr_accessor :client_scope

    def initialize(name, base_class)
      @name = name
      @base_class = base_class
      @client_scope = false
    end
    alias_method :method, :name

    def to_hash
      {
        name: @name,
        resource: resource_name,
        base_class: @base_class.underscore,
        location: location
      }
    end

    def resource_name
      @base_class.cached_attributes[@name]
    end

    # nil is a possible valid value for @client_scope when there is no scope
    def client_scope?
      @client_scope != false
    end

    def client
      fail ScopeNotSet.new(@name) if @client_scope == false
      @base_class.client_proc.call(client_scope)
    end

    def resource(override_client = nil)
      if resource = @base_class.resources[resource_name]
        resource.call(override_client || client)
      else
        fail ArgumentError.new("there is no resource named #{name} on #{@name}.")
      end
    end

    def location
      "#{@base_class.short_name}##{@name}"
    end

    def key
      return nil if @client_scope == false
      @key ||= AttributeKey.new(@base_class.underscore, resource_name,
                                @client_scope, @name)
    end
  end
end

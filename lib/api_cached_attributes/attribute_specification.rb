require 'api_cached_attributes/attribute_key'

module ApiCachedAttributes
  # A value object representing an attribute defined in
  # ApiCachedAttributes::Base. An AttributeSpecification contains the
  # attributes' method name, its resource, and its API client that is used for
  # lookup. It also calculates its `key` which is used to lookup its value in
  # storage.
  #
  # scope is evaluated outside of this object and should remain unchanged
  # throughout its life cycle. scope is used in building the attribute's key and
  # its equality. target_object on the other hand is just a reference to the
  # object that scope was evaluated on. It may change throughout the attribute's
  # life cycle and is not used in determining equality.
  class AttributeSpecification
    attr_reader :name, :base_class
    attr_accessor :scope, :target_object

    def initialize(name, base_class)
      @name = name
      @base_class = base_class
      @scope = false
    end
    alias_method :method, :name

    def to_hash
      {
        name: @name,
        resource: resource_name,
        base_class: @base_class.short_sym,
        location: location
      }
    end

    def resource_name
      @base_class.attributes[@name]
    end

    def location
      "#{@base_class.name}##{@name}"
    end

    # nil is a possible valid value for @scope when there is no scope
    def scope?
      @scope != false
    end

    def target_object?
      !!target_object
    end

    def client
      fail ScopeNotSet.new(@name) if @scope == false
      @base_class.client_proc.call(@scope)
    end

    def resource(override_client = nil)
      if resource = @base_class.resources[resource_name]
        resource.call(override_client || client)
      else
        fail ArgumentError, "there is no resource `#{name}` on #{base_class}."
      end
    end

    def key
      return nil if @scope == false
      @key ||= AttributeKey.new(@base_class.underscore, resource_name,
                                @scope, @name)
    end
  end
end

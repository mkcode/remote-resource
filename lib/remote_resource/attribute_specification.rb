require 'remote_resource/attribute_key'

module RemoteResource
  # A value object representing an attribute defined in
  # RemoteResource::Base. An AttributeSpecification contains the
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
    delegate :client, :with_error_handling, to: :@base_class

    def initialize(name, base_class)
      @name = name
      @base_class = base_class
    end
    alias_method :method, :name

    def to_hash
      {
        name: @name,
        resource: resource_name,
        base_class: @base_class.class.short_sym,
        location: location
      }
    end

    def resource_name
      @base_class.class.attributes[@name]
    end

    def resource(resource_client = nil)
      @base_class.send(:resource, resource_name, resource_client)
    end

    def location
      "#{@base_class.class.name}##{@name}"
    end

    def key
      @key ||= AttributeKey.new(@base_class.class.underscore, resource_name,
                                @base_class.scope, @name)
    end
  end
end

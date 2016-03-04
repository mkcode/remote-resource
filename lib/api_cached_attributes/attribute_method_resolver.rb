require_relative './attribute_specification'
require_relative './attribute_http_client'
require_relative './attribute_lookup'
require_relative './storage/storage_entry'
require 'api_cached_attributes/notifications'

module ApiCachedAttributes
  # Our humble lookup service
  class AttributeMethodResolver
    include ApiCachedAttributes::Notifications

    attr_reader :key_prefix, :attributes

    def initialize(base_class, options)
      @base_class = base_class
      @options = options
      @attributes = create_attributes!
    end

    def get(method, scope, named_resource = :default, target_instance)
      attribute = get_attribute_in_scope(method, scope)

      attr_lookup = ApiCachedAttributes.lookup_method
      lookup_name = attr_lookup.class.name
      instrument_attribute('find', attribute, lookup_method: lookup_name) do
        attr_lookup.find(attribute).value
      end
    end

    private

    def create_attributes!
      @base_class.cached_attributes.map do |method, value|
        AttributeSpecification.new(method, @base_class)
      end
    end

    def get_attribute(name)
      @attributes.detect { |attr| attr.name == name }
    end

    def get_attribute_in_scope(name, scope)
      attr = get_attribute(name)
      attr.client_scope = scope
      attr
    end
  end
end

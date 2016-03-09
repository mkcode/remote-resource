require 'api_cached_attributes/attribute_specification'
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

    def get(method, scope, _named_resource = :default, _target_instance)
      attribute = get_copied_attribute_with_scope(method, scope)

      attr_lookup = ApiCachedAttributes.lookup_method
      lookup_name = attr_lookup.class.name
      instrument_attribute('find', attribute, lookup_method: lookup_name) do
        attr_lookup.find(attribute).value
      end
    end

    private

    def create_attributes!
      @base_class.attributes.map do |method, _value|
        AttributeSpecification.new(method, @base_class)
      end
    end

    def find_attribute(name)
      @attributes.detect { |attr| attr.name == name }
    end

    # Internal: dup the attribute and set the new scope on it. This ensures that
    # nothing set on an attribute of the same previously will be carried over.
    def get_copied_attribute_with_scope(name, scope)
      attr = find_attribute(name).dup
      attr.client_scope = scope
      attr
    end
  end
end

module ApiCachedAttributes
  # Defines attribute related methods for Base class instances.
  module Attributes
    include ApiCachedAttributes::Notifications

    def create_attributes!(base_instance)
      base_instance.class.attributes.map do |method, _value|
        AttributeSpecification.new(method, base_instance)
      end
    end

    def get_attribute(name)
      attribute = find_attribute(name)

      attr_lookup = ApiCachedAttributes.lookup_method
      lookup_name = attr_lookup.class.name
      instrument_attribute('find', attribute, lookup_method: lookup_name) do
        attr_lookup.find(attribute).value
      end
    end

    # Internal: Returns the already created AttributeSpecification with the
    # provided name.
    def find_attribute(name)
      @attributes.detect { |attr| attr.name == name }
    end
  end
end

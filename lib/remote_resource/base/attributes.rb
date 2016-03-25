module RemoteResource
  # Defines attribute related methods for Base class instances.
  module Attributes
    include RemoteResource::Notifications

    # Public: Creates and returns an array of cached attributes for the provided
    # base_instance. The base_instance is stored in each attribute and is used
    # for lookup.
    #
    # base_instance - an instance of base_class. The instance means that the
    # scope has already been applied to it.
    #
    # Returns an array a AttributeSpecifications.
    def create_attributes(base_instance)
      @attributes = base_instance.class.attributes.map do |method, _value|
        AttributeSpecification.new(method, base_instance)
      end
    end

    # Public: Returns the value of the provided attribute. It uses the
    # application configured lookup_method to do so.
    #
    # name - a Symbol representing an attribute name
    #
    # Returns the value of the attribute as a String.
    def get_attribute(name)
      attribute = find_attribute(name)

      attr_lookup = RemoteResource.lookup_method
      lookup_name = attr_lookup.class.name
      instrument_attribute('find', attribute, lookup_method: lookup_name) do
        attr_lookup.find(attribute).value
      end
    end

    private

    # Internal: Returns the already created AttributeSpecification with the
    # provided name.
    def find_attribute(name)
      @attributes.detect { |attr| attr.name == name }
    end
  end
end

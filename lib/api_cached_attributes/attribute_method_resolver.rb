require 'active_support/core_ext/hash/reverse_merge'

require 'api_cached_attributes/attribute_specification'
require 'api_cached_attributes/notifications'

module ApiCachedAttributes
  # Our humble lookup service
  class AttributeMethodResolver
    include ApiCachedAttributes::Notifications

    attr_reader :attributes

    def initialize(base_class, options = {})
      @base_class = base_class
      @attributes = create_attributes!
      @options = ensure_options(options)
    end

    def get(method, target_object)
      attribute = get_copied_attribute_with_target_object(method, target_object)

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
    # nothing set on an attribute with the same name will be carried over.
    def get_copied_attribute_with_target_object(attr_name, target_object)
      attr = find_attribute(attr_name).dup
      attr.target_object = target_object
      attr.scope = eval_attribute_scope(target_object)
      attr
    end

    def eval_attribute_scope(target_object)
      scope = {}
      @options[:scope].each_pair do |attr_key, target_method|
        scope[attr_key.to_sym] = target_object.send(target_method.to_sym)
      end
      scope
    end

    def ensure_options(options)
      if ! options[:scope]
        options[:scope] = {}
      elsif options[:scope].is_a? Symbol
        options[:scope] = { options[:scope] => options[:scope] }
      elsif options[:scope].is_a? Array
        options[:scope] = {}.tap do |hash|
          options[:scope].each { |method| hash[method.to_sym] = method.to_sym }
        end
      end
      options
    end
  end
end

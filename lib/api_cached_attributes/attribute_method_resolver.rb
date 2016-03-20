require 'active_support/core_ext/hash/reverse_merge'

require 'api_cached_attributes/attribute_specification'
require 'api_cached_attributes/notifications'

module ApiCachedAttributes
  # The AttributeMethodResolver class is responsible for for creating
  # AttributeSpecifications with their scope and target object and kicking off
  # the lookup process for the attribute. An instance of the
  # AttributeMethodResolver class is created and saved on all domain objects
  # that call api_cached_attributes. The generated attributes method on that
  # domain class all call `get` on this class with the attribute method to
  # actually lookup the attribute value. The options passed to constructor of
  # this class are the same that are passed into the bridge.
  class AttributeMethodResolver
    include ApiCachedAttributes::Notifications

    attr_reader :attributes, :options

    # Public: Creates an instance of AttributeMethodResolver. This instance is
    # unsually saved on the target_object and used for lookup from the generated
    # methods.
    #
    # base_class - a descendant of ApiCachedAttributes::Base. This class gets
    #              the list of arguments from this base_class.
    #
    # options    - a hash of options. (default: {})
    #              :scope - the scope option represents the context in which
    #                       this api resource is unique. It has a similar
    #                       meaning to ActiveRecord's meaning of scope, as
    #                       opposed the API access meaning. The scope value can
    #                       be a Symbol, Array, or Hash. It is used to build the
    #                       scope argument, which is sent into the client and
    #                       resource blocks on the Base attributes class. This
    #                       argument to these blocks is always a hash, whose
    #                       values were methods responses evaluated on the
    #                       target_class.
    #
    # Returns an instance of AttributeMethodResolver.
    def initialize(base_class, options = {})
      @base_class = base_class
      @attributes = create_attributes!
      @options = ensure_options(options)
    end

    # Public: Lookup the value of the provided method (attribute) name in the
    # context of the provided target_object.
    #
    # method        - A symbol representing the name of the attribute that is to
    #                 be looked up. This should the same as an attribute defined
    #                 on the base_class given to the constructor of this class.
    # target_object - The context object. The scope argument given in the
    #                 constructor is evaluated on this object. It is usually an
    #                 instance of a domain object or ActiveRecord model.
    #
    # Returns a string of the API's response for this attribute.
    def get(method, target_object)
      attribute = get_copied_attribute_with_target_object(method, target_object)

      attr_lookup = ApiCachedAttributes.lookup_method
      lookup_name = attr_lookup.class.name
      instrument_attribute('find', attribute, lookup_method: lookup_name) do
        attr_lookup.find(attribute).value
      end
    end

    private

    # Internal: Create an attribute specification for each attribute defined on
    # the base class. These attributes are copied (duped) and then given their
    # scope and target_object before being used for lookup.
    def create_attributes!
      @base_class.attributes.map do |method, _value|
        AttributeSpecification.new(method, @base_class)
      end
    end

    # Internal: Returns the already created AttributeSpecification with the
    # provided name.
    def find_attribute(name)
      @attributes.detect { |attr| attr.name == name }
    end

    # Internal: dup the attribute and set the new scope on it. This ensures that
    # nothing set on an attribute with the same name will be carried over.
    def get_copied_attribute_with_target_object(attr_name, target_object)
      attr = find_attribute(attr_name).dup
      attr.target_object = target_object
      if @options[:scope].values.all? { |ov| ov.is_a? Symbol }
        attr.scope = eval_attribute_scope(target_object)
      else
        attr.scope = @options[:scope]
      end
      attr
    end

    # Internal: Returns a hash where the values of the scope have been evaluated
    # on the provided target_object.
    def eval_attribute_scope(target_object)
      scope = {}
      @options[:scope].each_pair do |attr_key, target_method|
        scope[attr_key.to_sym] = target_object.send(target_method.to_sym)
      end
      scope
    end

    # Internal: Normalizes the scope argument. Always returns the scope as a
    # Hash, despite it being able to be specified as a Symbol, Array, or Hash.
    # An undefined scope returns an empty Hash.
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

module ApiCachedAttributes
  # non-anonymous namespace for our generated methods. Mixed into the target
  # class so that introspection shows where the methods came from.
  class AttributeMethods < Module; end

  # Public: Creates an instance of the AttributeMethodAttacher, which is
  # responsible for setting up and attaching methods onto a target class which
  # are used to lookup cached attributes.
  class AttributeMethodAttacher
    attr_accessor :options
    # Public: Creates an instance of the AttributeMethodAttacher, which is
    # responsible for setting up and attaching methods onto a target class which
    # are used to lookup cached attributes.
    #
    # base_class - the class which will have methods attached to.
    # options - options hash with the following keys (default: {}). Generally,
    #           prefix should be used when overriding the names of all the
    #           methods is desired and attributes_map should be used when
    #           overriding only a few method names is desired.
    #     :prefix - prefix for the names of the newly created methods.
    #     :attributes_map - a hash for overriding method names to create. The
    #                       keys in this hash represent an attribute defined on
    #                       the base_class. The values are the overriding name
    #                       of the method to be defined on the target_class.
    #
    # Returns a new instance.
    def initialize(base_class, options = {})
      @base_class = base_class
      @options = ensure_options(options)
    end

    # Public: Set the base_classes' attribute methods on the given target class.
    # Sets a MethodResolver instance on the target_class as well. Logs warnings
    # if any methods on the target class are overwritten.
    #
    # target_class  - The class upon which the base_classes' attribute methods
    #                 should be set.
    # path_to_attrs - A string representing a line of ruby code that will be
    #                 evaluated. This line is the relative path from a
    #                 target_class instance to the object that holds the
    #                 attributes and where the `get_attribute` is defined. If
    #                 path_to_attrs is (default: self), that implies that this
    #                 is defining methods on the Base class, because that object
    #                 contains the `get_attribute` method.
    #
    # Returns the target_class
    def attach_to(target_class, path_to_attrs = 'self')
      overwrite_method_warnings(target_class) unless path_to_attrs == 'self'
      target_class.send(:include, make_attribute_methods_module(path_to_attrs))
    end

    private

    # Internal: Returns a module with the base_classes' attributes defined as
    # getter and setter methods.
    def make_attribute_methods_module(path_to_attrs)
      attribute_methods_module = AttributeMethods.new

      @base_class.attributes.keys.each do |attributes_method|
        method_name = @options[:attributes_map][attributes_method]
        method_name = "#{@options[:prefix]}_#{method_name}" if @options[:prefix]
        attribute_methods_module.module_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{method_name}
            #{path_to_attrs}.get_attribute(:#{attributes_method})
          end

          def #{method_name}=(other)
            fail ApiReadOnlyMethod.new('#{method_name}')
          end
        RUBY
      end
      attribute_methods_module
    end

    # Internal: Populate the attributes map. If no attributes_map arg is given,
    # then attributes_map is a 1 to 1 map (the default_attributes_map below).
    def ensure_options(options)
      options[:attributes_map] = default_attributes_map
                                 .merge(options[:attributes_map] || {})
      options
    end

    # Internal: Create a basic 1 to 1 (key to value) Hash map of the attribute
    # names. This is intended to be overridden by the attributes_map argument.
    def default_attributes_map
      {}.tap do |attr_map|
        @base_class.attributes.keys.each do |method|
          attr_map[method.to_sym] = method.to_sym
        end
      end
    end

    # Internal: Log warning methods when this attacher will overwrite methods on
    # the target class.
    def overwrite_method_warnings(target_class)
      @options[:attributes_map].values.each do |method|
        method = "#{@options[:prefix]}_#{method}" if @options[:prefix]
        if present_and_future_public_methods(target_class).include? method
          log_msg =  "#{@base_class.name} is overwriting the "
          log_msg += "#{method} method on #{target_class.name}"
          ApiCachedAttributes.logger.warn log_msg
        end
      end
    end

    # Internal: ActiveRecord objects do not define a model's column methods
    # until the instance is created. In this context, we have the class, so we
    # lookup the 'future methods' on the `column_names` class method.
    def present_and_future_public_methods(target_class)
      conflicts = target_class.public_instance_methods
      if target_class.respond_to? :column_names
        conflicts += target_class.column_names.map(&:to_sym)
      end
      conflicts
    end
  end
end

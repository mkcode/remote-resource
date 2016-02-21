module ApiCachedAttributes
  class ApiReadOnlyMethod < StandardError; end;

  # Our humble method maker
  class MethodMaker
    def initialize(attributes_class, options)
      @attributes_class = attributes_class
      @options = options
    end

    def define_methods_on(klass_object)
      @attributes_class.cached_attributes.each_pair do |method, value|
        klass_object.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{method}
            puts "woot"
          end

          def #{method}=(other)
            msg = "`#{method}` was created by the `ApiCachedAttributes` gem, which "
            msg += "only supports allows for getters from the API. Though, you "
            msg += "may override this method on `#{klass_object.name}`."
            fail ApiCachedAttributes::ApiReadOnlyMethod.new(msg)
          end
        RUBY
      end
    end

    private

    def define_attribute_reader_method

    end
  end
end

require_relative './lookup_service'

module ApiCachedAttributes
  class ApiReadOnlyMethod < StandardError; end;

  # Our humble lookup service attacher
  class LookupServiceAttacher
    def initialize(base_class, options)
      @base_class = base_class
      @options = options
    end

    def define_methods_on(target_class)
      lookup_service = LookupService.new(@base_class, @options)
      lookup_target_var = "@#{@base_class.underscore}_lookup".to_sym
      target_class.instance_variable_set(lookup_target_var, lookup_service)

      @base_class.cached_attributes.each_pair do |method, value|
        target_class.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{method}
            key_peices = {
              method: "#{method}",
              attributes_class: "#{@base_class.name}",
              # response_name: #{},
              scope: #{@options[:scope]}
            }
            key = CacheKey.for(key_peices)
            # CachedResponseLookup.find()
          end

          def #{method}=(other)
            msg = "`#{method}` was created by the `ApiCachedAttributes` gem, "
            msg += "which only supports API getters. Although, you "
            msg += "may override this method on `#{target_class.name}`."
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

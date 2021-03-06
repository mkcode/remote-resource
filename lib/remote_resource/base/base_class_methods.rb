module RemoteResource
  # Methods that help with loading and naming the Base class.
  module BaseClassMethods
    def find_descendant(which_class)
      ensure_loaded(which_class)
      descendants.detect do |descendant|
        descendant.symbol_name == which_class.to_sym
      end
    end

    def ensure_loaded(which_class)
      which_class.to_s.camelize.safe_constantize
    end

    def underscore
      name.underscore
    end

    def symbol_name
      underscore.to_sym
    end
  end
end

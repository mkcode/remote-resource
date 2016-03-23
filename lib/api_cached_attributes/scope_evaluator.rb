module ApiCachedAttributes
  class ScopeEvaluator
    def initialize(scope = nil)
      @scope = normalize_scope(scope)
    end

    # Internal: Returns a Boolean indicating whether or not the scope should be
    # looked up (evaluated on) the target_object. This allows direct values for
    # the scope to be used, rather then references to methods on the target
    # object.
    def should_eval_attribute_scope?
      @scope.values.all? { |scope_value| scope_value.is_a? Symbol }
    end

    # Internal: Returns a hash where the values of the scope have been evaluated
    # on the provided target_object.
    def eval_attribute_scope(target_object)
      scope = {}
      @scope.each_pair do |attr_key, target_method|
        scope[attr_key.to_sym] = target_object.send(target_method.to_sym)
      end
      scope
    end

    # Internal: Normalizes the scope argument. Always returns the scope as a
    # Hash, despite it being able to be specified as a Symbol, Array, or Hash.
    # An undefined scope returns an empty Hash.
    def normalize_scope(scope)
      if ! scope
        scope = {}
      elsif scope.is_a? Symbol
        scope = { scope => scope }
      elsif scope.is_a? Array
        scope = {}.tap do |hash|
          scope.each { |method| hash[method.to_sym] = method.to_sym }
        end
      end
      scope
    end
  end
end

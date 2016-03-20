require 'active_support/descendants_tracker'

module ApiCachedAttributes
  # the base class for defining an api.
  class Base
    extend ActiveSupport::DescendantsTracker

    extend ApiCachedAttributes::BaseClassMethods
    extend ApiCachedAttributes::Dsl

    def initialize(**args)
      @scope = args
      aa = AttributeMethodAttacher.new(self.class, scope: @scope)
      aa.attach_to(self.class)
    end

    def client
      fail ScopeNotSet.new(self.class.name) if @scope == false
      self.class.client_proc.call(@scope)
    end

    def resource(name)
      if (resource = self.class.resources[name])
        resource.call(client, @scope)
      else
        msg = "there is no resource named `#{name}` on #{self.class.name}."
        fail ArgumentError, msg
      end
    end
  end
end

require 'active_support/descendants_tracker'

module ApiCachedAttributes
  # the base class for defining an api.
  class Base
    extend ActiveSupport::DescendantsTracker

    extend ApiCachedAttributes::BaseClassMethods
    extend ApiCachedAttributes::Dsl

    include ApiCachedAttributes::Attributes
    include ApiCachedAttributes::Rescue

    attr_reader :scope

    def initialize(**args)
      @scope = args
      create_attributes(self)
      AttributeMethodAttacher.new(self.class).attach_to(self.class)
    end

    def client
      self.class.client_proc.call(@scope)
    end

    def resource(name = :default, resource_client = nil)
      if (attr_resource = self.class.resources[name])
        attr_resource.call(resource_client || client, @scope)
      else
        msg = "there is no resource named `#{name}` on #{self.class.name}."
        fail ArgumentError, msg
      end
    end
  end
end

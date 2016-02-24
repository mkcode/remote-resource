module ApiCachedAttributes
  # Yes
  class CachedAttribute
    attr_reader :name, :resource_name

    def initialize(name, resource_name)
      @name = name
      @resource_name = resource_name
    end
    alias_method :method, :name
  end
end

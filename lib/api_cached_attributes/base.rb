require 'active_support/descendants_tracker'

module ApiCachedAttributes
  # the base class for defining an api.
  class Base
    extend ActiveSupport::DescendantsTracker

    extend ApiCachedAttributes::BaseClassMethods
    extend ApiCachedAttributes::Dsl
  end
end

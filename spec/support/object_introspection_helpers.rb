module ObjectIntrospectionHelpers
  def self.included(base_klass)
    base_klass.extend ClassMethods
  end

  module ClassMethods
    alias_method :ivar_get, :instance_variable_get
  end
end

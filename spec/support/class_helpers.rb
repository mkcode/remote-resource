module ClassHelpers
  def stub_class(name, superclass = nil, &block)
    stub_const(name.to_s.camelize, Class.new(superclass || Object, &block))
  end

  def stub_base_class(name, &block)
    ActiveSupport::DescendantsTracker.clear
    stub_class(name, RemoteResource::Base, &block)
  end
end

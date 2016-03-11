

def stub_class(name, superclass = nil, &block)
  stub_const(name.to_s.camelize, Class.new(superclass || Object, &block))
end

def base_class(name, &block)
  ActiveSupport::DescendantsTracker.clear
  class_name = name.end_with?('Attributes') ? name : name + 'Attributes'
  stub_class(class_name, ApiCachedAttributes::Base, &block)
end

def fake_octokit_client
  fake = double()
  user_response = double()
  allow(user_response).to receive(:login).and_return('mkcode')
  allow(fake).to receive(:user).and_return(user_response)
end

require 'spec_helper'

describe ApiCachedAttributes::AttributeMethodAttacher do
  let(:attributes_class) do
    stub_base_class 'GithubUser' do
      attribute :login
    end
  end
  let(:target_class) do
    Class.new.tap { |c| c.send(:include, ObjectIntrospectionHelpers) }
  end
  subject { described_class.new(attributes_class) }
  before  { subject.attach_to(target_class) }

  describe '.attach_to' do
    it 'sets an AttributeMethodResolver on the supplied class' do
      expected_var_name = subject.send(:method_resolver_var)
      expect(target_class.ivar_get(expected_var_name))
        .to be_an ApiCachedAttributes::AttributeMethodResolver
    end

    it 'includes the AttributeMethods on the supplied class' do
      expect(target_class.included_modules.map(&:class))
        .to include ApiCachedAttributes::AttributeMethods
    end
  end

  describe 'attacher defined methods' do
    it 'calling a getter method calls get on the method resolver' do
      method = attributes_class.attributes.keys.first
      expected_var_name = subject.send(:method_resolver_var)
      resolver = target_class.ivar_get(expected_var_name)
      expect(resolver).to receive(:get)
      target_class.new.send(method)
    end

    it 'calling a setter method raises an ApiReadOnlyMethod error' do
      getter_method = attributes_class.attributes.keys.first
      setter_method = (getter_method.to_s + '=').to_sym
      expect { target_class.new.send(setter_method, '') }
        .to raise_error(ApiCachedAttributes::ApiReadOnlyMethod)
    end
  end
end

describe ApiCachedAttributes::AttributeMethods do
  let(:attributes_class) do
    stub_base_class 'GithubUser' do
      attribute :login
      attribute :avatar_url
    end
  end
  let(:attacher_class) do
    ApiCachedAttributes::AttributeMethodAttacher.new(attributes_class)
  end
  subject { attacher_class.send(:make_attribute_methods_module) }

  it 'has a getter method for each attribute in the attributes class' do
    attributes_class.attributes.each_pair do |attr, _|
      expect(subject.public_instance_methods).to include(attr)
    end
  end

  it 'has a setter method for each attribute in the attributes class' do
    attributes_class.attributes.each_pair do |attr, _|
      setter_name = (attr.to_s + '=').to_sym
      expect(subject.public_instance_methods).to include(setter_name)
    end
  end
end

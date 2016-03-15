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

  describe '.attach_to' do
    context 'on the supplied (target) class' do
      before  { subject.attach_to(target_class) }

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

    context 'when overwriting a method on the target class' do
      it 'logs a warning message' do
        expect(ApiCachedAttributes.logger).to receive(:warn)
        target_class = Class.new
        target_class.send(:define_method, :login, -> {})
        subject.attach_to(target_class)
      end
    end

    context 'when the prefix option distinguishes the methods' do
      it 'does not log a warning message' do
        subject.options.merge!({ prefix: 'prefixed' })
        expect(ApiCachedAttributes.logger).to_not receive(:warn)
        target_class = Class.new
        target_class.send(:define_method, :login, -> {})
        subject.attach_to(target_class)
      end
    end
  end

  describe 'attacher defined methods' do
    before  { subject.attach_to(target_class) }

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

  it 'respects the constructors prefix argument' do
    attacher_class.options.merge!(prefix: 'prefixed')
    attributes_class.attributes.each_pair do |attr, _|
      prefixed_name = ('prefixed_' + attr.to_s).to_sym
      expect(subject.public_instance_methods).to include(prefixed_name)
    end
  end

  it 'respects the constructors attributes_map argument' do
    attr_map = attacher_class.options[:attributes_map].merge(login: :overide)
    attacher_class.options.merge!(attributes_map: attr_map)
    attributes_class.attributes.each_pair do |attr, _|
      attr_with_overides = attr.to_s.sub('login', 'overide').to_sym
      expect(subject.public_instance_methods).to include(attr_with_overides)
    end
  end
end

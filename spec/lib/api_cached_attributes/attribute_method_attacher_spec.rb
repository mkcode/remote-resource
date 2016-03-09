require 'spec_helper'

describe ApiCachedAttributes::AttributeMethodAttacher do
  let(:attributes_class) { base_class 'GithubUser' }
  subject                { described_class.new(attributes_class) }
  let(:target_class)     { Class.new }

  describe '.attach_to' do
    before { subject.attach_to(target_class) }

    it 'sets an AttributeMethodResolver on the supplied class' do
      expected_var_name = subject.send(:method_resolver_var)
      expect(target_class.instance_variable_get(expected_var_name))
        .to be_an ApiCachedAttributes::AttributeMethodResolver
    end

    it 'includes the AttributeMethods on the supplied class' do
      expect(target_class.included_modules.map(&:class))
        .to include ApiCachedAttributes::AttributeMethods
    end
  end
end

require 'spec_helper'

describe ApiCachedAttributes::AttributeMethodAttacher do
  let(:attributes_class) do
    base_class 'GithubUser' do
      attribute(:user)
    end
  end

  describe '.attach_to' do
    subject { described_class.new(attributes_class, test_key: 'value') }
    let(:target_class) { Class.new }

    it 'sets an AttributeMethodResolver on the supplied class' do
      subject.attach_to(target_class)
      expected_var_name = subject.send(:method_resolver_var)
      expect(target_class.instance_variable_get(expected_var_name))
        .to be_an ApiCachedAttributes::AttributeMethodResolver
    end
  end
end

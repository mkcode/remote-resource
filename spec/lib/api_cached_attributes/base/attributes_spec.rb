require 'spec_helper'

describe ApiCachedAttributes::Attributes do
  let(:attr_class) do
    stub_base_class 'GithubUser' do
      attribute :login
      attribute :avatar_url
    end
  end

  subject do
    Object.new.tap { |c| c.send(:extend, ApiCachedAttributes::Attributes) }
  end

  describe '#create_attributes' do
    it 'returns an array of AttributeSpecifications for the attributes class' do
      attrs = subject.create_attributes(attr_class.new)
      expect(attrs.map(&:name)).to eq([:login, :avatar_url])
    end
  end
end

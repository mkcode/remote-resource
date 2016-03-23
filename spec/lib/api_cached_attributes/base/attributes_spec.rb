require 'spec_helper'

describe ApiCachedAttributes::Attributes do
  let(:attr_class) do
    stub_base_class 'GithubUser' do
      attribute :login
      attribute :avatar_url
    end
  end

  subject do
    base_class = Class.new
    base_class.send(:include, ApiCachedAttributes::Attributes)
    base_class.new.tap { |bc| bc.create_attributes(attr_class.new) }
  end

  describe '#create_attributes' do
    it 'returns an array of AttributeSpecifications for the attributes class' do
      attrs = subject.create_attributes(attr_class.new)
      expect(attrs.map(&:name)).to eq([:login, :avatar_url])
    end
  end

  describe '#get_attribute' do
    before do
      ApiCachedAttributes.lookup_method =
        ApiCachedAttributes::Lookup::Default.new
      allow(ApiCachedAttributes.lookup_method)
        .to receive_message_chain('find.value')
    end

    it 'calls find on the configured ApiCachedAttributes lookup_method' do
      lookup_double = double()
      expect(lookup_double).to receive_message_chain('find.value')
      ApiCachedAttributes.lookup_method = lookup_double
      subject.get_attribute(:login)
    end

    it 'instruments find' do
      expect(ActiveSupport::Notifications)
        .to receive(:instrument)
        .with('find.api_cached_attributes', any_args)
      subject.get_attribute(:login)
    end
  end
end

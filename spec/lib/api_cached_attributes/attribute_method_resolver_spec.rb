require 'spec_helper'

describe ApiCachedAttributes::AttributeMethodResolver do
  let(:attr_class) do
    stub_base_class 'GithubUser' do
      attribute :login
      attribute :avatar_url
    end
  end

  describe '#initialize' do
    it 'creates attributes' do
      resolver = described_class.new(attr_class)
      expect(resolver.attributes.map(&:name)).to eq([:login, :avatar_url])
    end
  end

  describe '.get' do
    before do
      ApiCachedAttributes.lookup_method =
        ApiCachedAttributes::Lookup::Default.new
      allow(ApiCachedAttributes.lookup_method)
        .to receive_message_chain('find.value')
    end
    subject { described_class.new(attr_class) }

    it 'calls find on the configured ApiCachedAttributes lookup_method' do
      lookup_double = double()
      expect(lookup_double).to receive_message_chain('find.value')
      ApiCachedAttributes.lookup_method = lookup_double
      subject.get(:login, Object.new)
    end

    it 'instruments find' do
      expect(ActiveSupport::Notifications)
        .to receive(:instrument)
        .with('find.api_cached_attributes', any_args)
      subject.get(:login, Object.new)
    end

    it 'looks up the values of the scope hash on the target_object' do
      new_scope = { key1: :my_method, key2: :other_method }
      subject.instance_variable_set(:@options, { scope: new_scope })
      target_class = double()
      expect(target_class).to receive(:my_method)
      expect(target_class).to receive(:other_method)
      subject.get(:login, target_class)
    end
  end
end

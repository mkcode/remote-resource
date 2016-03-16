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

    context 'without a scope argument' do
      it 'sets the scope to an empty hash' do
        resolver = described_class.new(attr_class)
        expect(resolver.options[:scope]).to eq({})
      end
    end

    context 'with a symbol scope argument' do
      it 'sets the scope to a hash with the symbol as the key and value' do
        resolver = described_class.new(attr_class, scope: :id)
        expect(resolver.options[:scope]).to eq({ id: :id })
      end
    end

    context 'with an array scope argument' do
      it 'sets scope to a hash with the symbols as the keys and values' do
        resolver = described_class.new(attr_class, scope: [:id, :other])
        expect(resolver.options[:scope]).to eq({ id: :id, other: :other })
      end
    end

    context 'with a hash scope argument' do
      it 'sets the scope to the supplied hash' do
        resolver = described_class.new(attr_class, scope: { key: :value })
        expect(resolver.options[:scope]).to eq({ key: :value })
      end
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

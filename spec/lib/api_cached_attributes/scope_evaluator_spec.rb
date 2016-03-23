require 'spec_helper'

describe ApiCachedAttributes::ScopeEvaluator do
  let(:attr_class) do
    stub_base_class 'GithubUser' do
      attribute :login
      attribute :avatar_url
    end
  end

  describe '#initialize' do
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
end

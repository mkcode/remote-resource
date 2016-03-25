require 'spec_helper'

describe RemoteResource::ScopeEvaluator do
  describe '#initialize' do
    context 'without a scope argument' do
      it 'sets the scope to an empty hash' do
        scope_evaluator = described_class.new()
        expect(scope_evaluator.scope).to eq({})
      end
    end

    context 'with a symbol scope argument' do
      it 'sets the scope to a hash with the symbol as the key and value' do
        scope_evaluator = described_class.new(:id)
        expect(scope_evaluator.scope).to eq({ id: :id })
      end
    end

    context 'with an array scope argument' do
      it 'sets scope to a hash with the symbols as the keys and values' do
        scope_evaluator = described_class.new([:id, :other])
        expect(scope_evaluator.scope).to eq({ id: :id, other: :other })
      end
    end

    context 'with a hash scope argument' do
      it 'sets the scope to the supplied hash' do
        scope_evaluator = described_class.new({ key: :value })
        expect(scope_evaluator.scope).to eq({ key: :value })
      end
    end
  end
end

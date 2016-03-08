require 'spec_helper'

describe ApiCachedAttributes::DSL do
  subject do
    Class.new(ApiCachedAttributes::Base).tap do |base_class|
      base_class.send(:include, ObjectIntrospectionHelpers)
    end
  end

  describe '.client' do
    it 'sets the supplied block to @client_proc' do
      subject.client { 'client' }
      expect(subject.ivar_get(:@client_proc).call()).to eq('client')
    end
  end

  describe '.named_resource' do
    let(:mock_client) do
      Object.new.tap do |ob|
        allow(ob).to receive(:user).and_return('client_user')
      end
    end

    it 'adds the supplied block to the @resources hash' do
      subject.named_resource(:user) { |client| client.user }
      expect(subject.ivar_get(:@resources)[:user].call(mock_client))
        .to eq('client_user')
    end

    it 'raises an ArgumentError if no block is given' do
      expect { subject.named_resource(:user) }
        .to raise_error(ArgumentError)
    end
  end

  describe '.default_resource' do
    let(:mock_client) do
      Object.new.tap do |ob|
        allow(ob).to receive(:user).and_return('default_user')
      end
    end

    it 'sets the supplied block to the @resources[:default]' do
      subject.default_resource { |client| client.user }
      expect(subject.ivar_get(:@resources)[:default].call(mock_client))
        .to eq('default_user')
    end
  end

  describe '.attribute' do
    it 'sets the named method to resource in the @attributes hash' do
      subject.attribute(:description, :repository)
      expect(subject.ivar_get(:@attributes)[:description])
        .to eq(:repository)
    end

    context 'when no second argument is given' do
      it 'sets the named method to default in the @attributes hash' do
        subject.attribute(:login)
        expect(subject.ivar_get(:@attributes)[:login])
          .to eq(:default)
      end
    end
  end

  describe '.attributes' do
    context 'when no attributes were set' do
      it 'sets the named method to resource in the @attributes hash' do
        expect(subject.attributes).to eq({})
      end
    end

    context 'when attributes were set' do
      it 'returns the set attributes' do
        subject.attribute(:login)
        subject.attribute(:description, :repository)
        expect(subject.attributes).to eq(login: :default,
                                         description: :repository)
      end
    end
  end
end

require 'spec_helper'

describe ApiCachedAttributes::AttributeSpecification do
  let(:attributes_class) do
    stub_base_class "GithubUser" do
      default_resource(&:user)
      attribute :login
      attribute :description, :rails_repo
    end
  end
  let(:subject)     { described_class.new(:login, attributes_class) }
  let(:alt_subject) { described_class.new(:description, attributes_class) }

  describe '#name (alias #method)' do
    it 'returns the name supplied to the constructor' do
      expect(subject.name).to eq(:login)
    end
  end

  describe '#base_class' do
    it 'returns the base_class supplied to the constructor' do
      expect(subject.base_class).to equal(attributes_class)
    end
  end

  describe '#to_hash' do
    it 'returns a hash representation of the attribute' do
      expect(subject.to_hash).to eq(
        name: :login,
        resource: :default,
        base_class: :github_user,
        location: 'GithubUserAttributes#login'
      )
    end
  end

  describe '#resource_name' do
    it 'returns the resource name of the attribute set on the base_class' do
      expect(subject.resource_name).to eq(:default)
    end
  end

  describe '#location' do
    it 'returns the attributes class name and method' do
      expect(subject.location).to eq('GithubUserAttributes#login')
    end
  end

  describe '#scope?' do
    context 'when the scope has not been set' do
      it 'returns false' do
        expect(subject.scope?).to eq(false)
      end
    end

    context 'when the scope has been set' do
      it 'returns true' do
        subject.scope = { access_token: 'abc123' }
        expect(subject.scope?).to eq(true)
      end
    end
  end

  describe '#target_object?' do
    context 'when the target object has not been set' do
      it 'returns false' do
        expect(subject.target_object?).to eq(false)
      end
    end

    context 'when the target object has been set' do
      it 'returns true' do
        subject.target_object = Object.new
        expect(subject.target_object?).to eq(true)
      end
    end
  end

  describe '#client' do
    context 'when the scope has not been set' do
      it 'raises a ScopeNotSet error' do
        expect { subject.client }
          .to raise_error(ApiCachedAttributes::ScopeNotSet)
      end
    end

    context 'when the scope has been set' do
      it 'evaluates the set client with the scope' do
        subject.scope = { access_token: 'abc123' }
        attributes_class.client { |scope| scope }
        expect(subject.client).to eq(subject.scope)
      end
    end
  end

  describe '#resource' do
    context 'when the attributes specified resource does not exist' do
      it 'raise an ArgumentError' do
        expect { alt_subject.resource }.to raise_error(ArgumentError)
      end
    end

    context 'when the attributes specified resource exists' do
      it 'evaluates the set resource with the client' do
        subject.scope = { access_token: 'abc123' }
        fake_client = double()
        allow(fake_client).to receive(:user).and_return('mkcode')
        attributes_class.client { |scope| fake_client }
        expect(subject.resource).to eq('mkcode')
      end
    end
  end

  describe '#key' do
    context 'when the scope has not been set' do
      it 'returns nil' do
        expect(subject.key).to be_nil
      end
    end

    context 'when the scope has been set' do
      it 'returns an instance of AttributeKey' do
        subject.scope = { access_token: 'abc123' }
        expect(subject.key).to be_an(ApiCachedAttributes::AttributeKey)
      end

      it 'the returned key has the correct parameters set on it' do
        subject.scope = { access_token: 'abc123' }
        expect(subject.key.to_s)
          .to eq('github_user_attributes/access_token=abc123/default/login')
      end
    end
  end
end

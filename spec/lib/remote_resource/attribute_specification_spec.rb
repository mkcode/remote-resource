require 'spec_helper'

describe RemoteResource::AttributeSpecification do
  let(:attr_class) do
    stub_base_class "GithubUser" do
      attribute :login
      attribute :desc, :rails_repo
    end
  end
  let(:subject) { described_class.new(:login, attr_class.new) }
  let(:alt_subject) do
    described_class.new(:desc, attr_class.new(access_token: 'abc123'))
  end

  describe '#name (alias #method)' do
    it 'returns the name supplied to the constructor' do
      expect(subject.name).to eq(:login)
    end
  end

  describe '#base_class' do
    it 'returns the base_class instance supplied to the constructor' do
      expect(subject.base_class.class.name).to eq('GithubUser')
    end
  end

  describe '#to_hash' do
    it 'returns a hash representation of the attribute' do
      expect(subject.to_hash).to eq(
        name: :login,
        resource: :default,
        base_class: :github_user,
        location: 'GithubUser#login'
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
      expect(subject.location).to eq('GithubUser#login')
    end
  end

  describe '#client' do
    it 'evaluates the set client with the scope' do
      scope = { access_token: 'abc123' }
      subject.base_class.instance_variable_set(:@scope, scope)
      attr_class.client { |scope| scope }
      expect(subject.client).to eq(scope)
    end
  end

  describe '#resource' do
    context 'when the attributes specified resource does not exist' do
      it 'raise an ArgumentError' do
        attr_class.default_resource(&:user)
        expect { alt_subject.resource }.to raise_error(ArgumentError)
      end
    end

    context 'when the attributes specified resource exists' do
      it 'evaluates the set resource yielding the client and scope' do
        scope = { access_token: 'abc123' }
        subject.base_class.instance_variable_set(:@scope, scope)
        fake_client = double()
        allow(fake_client).to receive(:user).and_return('mkcode')
        attr_class.client { |scope| fake_client }
        attr_class.default_resource { |c, s| c.user + s[:access_token] }
        expect(subject.resource).to eq('mkcodeabc123')
      end
    end
  end

  describe '#key' do
    it 'returns an instance of AttributeKey' do
      expect(subject.key).to be_an(RemoteResource::AttributeKey)
    end

    it 'the returned key has the correct parameters set on it' do
      expect(alt_subject.key.to_s)
        .to eq('github_user/access_token=abc123/rails_repo/desc')
    end
  end
end

require 'spec_helper'

describe ApiCachedAttributes::AttributeSpecification do
  let(:attributes_class) do
    base_class "GithubUser" do
      default_resource(&:user)
      named_resource(:rails_repo) do |client|
        client.repo('rails/rails')
      end
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
end

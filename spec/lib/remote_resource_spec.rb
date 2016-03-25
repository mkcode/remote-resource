require 'spec_helper'

describe RemoteResource do
  it 'has a version number' do
    expect(RemoteResource::VERSION).not_to be nil
  end

  it 'includes its required configuration modules' do
    [
      RemoteResource::Configuration::LookupMethod,
      RemoteResource::Configuration::Storage,
      RemoteResource::Configuration::Logger
    ].each do |klass|
      expect(RemoteResource.singleton_class.ancestors).to include(klass)
    end
  end
end

describe RemoteResource::Base do
  describe '.find_descendant' do
    before do
      stub_base_class 'GithubUser'
    end

    it 'returns an RemoteResource::Base class descendant' do
      descendant = RemoteResource::Base.find_descendant(:github_user)
      expect(descendant.superclass).to eq(RemoteResource::Base)
    end

    it 'matches descendants on its full name' do
      desc = RemoteResource::Base.find_descendant(:github_user_attributes)
      expect(desc.superclass).to eq(RemoteResource::Base)
    end

    it 'returns nil if the provided class does not exist' do
      descendant = RemoteResource::Base.find_descendant(:not_a_github_user)
      expect(descendant).to be_nil
    end
  end

  context 'class name convenience methods' do
    subject { stub_base_class 'GithubUserAttributes' }

    describe '.underscore' do
      it 'returns the underscored name of the class' do
        expect(subject.underscore).to eq('github_user_attributes')
      end
    end

    describe '.short_name' do
      it 'returns the short name of the class' do
        expect(subject.short_name).to eq('GithubUser')
      end
    end

    describe '.short_sym' do
      it 'returns the short symbol name of the class' do
        expect(subject.short_sym).to eq(:github_user)
      end
    end
  end
end

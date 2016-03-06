require 'spec_helper'

describe ApiCachedAttributes do
  it 'has a version number' do
    expect(ApiCachedAttributes::VERSION).not_to be nil
  end

  it 'includes its required configuration modules' do
    [
      ApiCachedAttributes::Configuration::LookupMethod,
      ApiCachedAttributes::Configuration::Storage,
      ApiCachedAttributes::Configuration::Logger
    ].each do |klass|
      expect(ApiCachedAttributes.singleton_class.ancestors).to include(klass)
    end
  end
end

describe ApiCachedAttributes::Base do
  describe '.find_descendant' do
    before do
      ActiveSupport::DescendantsTracker.clear
      base_class 'GithubUser'
    end

    it 'returns an ApiCachedAttributes::Base class descendant' do
      descendant = ApiCachedAttributes::Base.find_descendant(:github_user)
      expect(descendant.superclass).to eq(ApiCachedAttributes::Base)
    end

    it 'matches descendants on its full name' do
      desc = ApiCachedAttributes::Base.find_descendant(:github_user_attributes)
      expect(desc.superclass).to eq(ApiCachedAttributes::Base)
    end

    it 'returns nil if the provided class does not exist' do
      descendant = ApiCachedAttributes::Base.find_descendant(:not_a_github_user)
      expect(descendant).to be_nil
    end
  end

  context 'class name convenience methods' do
    subject { base_class 'GithubUserAttributes' }

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

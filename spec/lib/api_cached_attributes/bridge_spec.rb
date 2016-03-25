require 'spec_helper'

describe ApiCachedAttributes::Bridge do
  before  { stub_base_class 'GithubUser' }
  subject { Class.new.tap { |o| o.extend(described_class) } }

  shared_examples 'a Resource class finder' do |test_method|
    context 'when the first argument is an existing Resource descendant' do
      it 'does not raise an error' do
        expect { subject.send(test_method, :github_user) }
          .to_not raise_error
      end
    end

    context 'when the first argument is not an existing Resource descendant' do
      it 'raises a BaseClassNotFound error' do
        expect { subject.send(test_method, :does_not_exist) }
          .to raise_error ApiCachedAttributes::BaseClassNotFound
      end
    end
  end

  shared_examples 'an AssociationBuilder method' do |test_method|
    it 'creates and uses the AssociationBuilder' do
      expect_any_instance_of(ApiCachedAttributes::AssociationBuilder)
        .to receive(:associated_with).with(subject).and_call_original
      subject.send(test_method, :github_user)
    end

    it 'creates an association method on self' do
      subject.send(test_method, :github_user)
      expect(subject.new.github_user_attributes).to be_a(GithubUserAttributes)
    end
  end

  describe '.has_remote' do
    it_behaves_like 'a Resource class finder', :has_remote
    it_behaves_like 'an AssociationBuilder method', :has_remote

    it 'does not tell the AttributeMethodAttacher to define methods on self' do
      expect_any_instance_of(ApiCachedAttributes::AttributeMethodAttacher)
        .to_not receive(:attach_to).with(subject)
      subject.has_remote(:github_user)
    end
  end

  describe '.embed_remote' do
    it_behaves_like 'a Resource class finder', :embed_remote
    it_behaves_like 'an AssociationBuilder method', :embed_remote

    it 'instructs the AttributeMethodAttacher to define methods on self' do
      expect_any_instance_of(ApiCachedAttributes::AttributeMethodAttacher)
        .to receive(:attach_to).with(subject, 'github_user_attributes')
      subject.embed_remote(:github_user)
    end
  end
end

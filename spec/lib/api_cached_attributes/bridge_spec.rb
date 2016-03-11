require 'spec_helper'

describe ApiCachedAttributes::Bridge do
  before  { stub_base_class 'GithubUser' }
  subject { Class.new.tap { |o| o.extend(described_class) } }

  describe '.api_cached_attributes' do
    context 'when the first argument is an existing ::Base descendant' do
      it 'does not raise an error' do
        expect { subject.api_cached_attributes(:github_user) }
          .to_not raise_error
      end

      it 'instructs the AttributeMethodAttacher to attach_to itself' do
        expect_any_instance_of(ApiCachedAttributes::AttributeMethodAttacher)
          .to receive(:attach_to).with(subject)
        subject.api_cached_attributes(:github_user)
      end
    end

    context 'when the first argument is not an existing ::Base descendant' do
      it 'raises a BaseClassNotFound error' do
        expect { subject.api_cached_attributes(:does_not_exist) }
          .to raise_error ApiCachedAttributes::BaseClassNotFound
      end
    end
  end
end

require 'spec_helper'

describe ApiCachedAttributes::AttributeMethodResolver do
  let(:attributes_class) do
    stub_base_class 'GithubUser' do
      attribute :login
    end
  end
  subject { described_class.new(attributes_class) }

  describe '.get' do
    it 'calls find on the configured ApiCachedAttributes lookup_method' do
      lookup_double = double()
      expect(lookup_double).to receive_message_chain('find.value')
      ApiCachedAttributes.lookup_method = lookup_double
      subject.get(:login, Object.new)
    end

    it 'instruments find' do
      expect(ActiveSupport::Notifications)
        .to receive(:instrument)
        .with('find.api_cached_attributes', any_args)
      subject.get(:login, Object.new)
    end
  end
end

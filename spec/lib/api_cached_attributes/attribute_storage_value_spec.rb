require 'spec_helper'
require 'api_cached_attributes/storage/memory'

describe ApiCachedAttributes::AttributeStorageValue do
  let(:attrs_class) do
    foc = fake_octokit_client
    stub_base_class 'GithubUser' do
      client { |scope| foc }
      default_resource(&:user)
      attribute :login
    end
  end
  let(:attribute) do
    ApiCachedAttributes::AttributeSpecification.new(:login, attrs_class.new)
  end
  before do
    ApiCachedAttributes.storages = [ApiCachedAttributes::Storage::Memory.new]
  end
  subject { described_class.new(attribute) }

  describe '#value' do
    it 'returns the value' do
      subject.write ApiCachedAttributes::StorageEntry.new({}, {login: 'mkcode'})
      expect(subject.value).to eq('mkcode')
    end
  end

  describe '#storages' do
    it 'returns the storages set on the main class' do
      ApiCachedAttributes.storages = ['test_storage']
      expect(subject.storages).to eq(['test_storage'])
    end
  end

  describe '#storage_entry' do
    context 'when the attribute value does not exist in any storages' do
      it 'returns a NullStorageEntry' do
        expect(subject.storage_entry)
          .to be_a ApiCachedAttributes::NullStorageEntry
      end
    end

    context 'when the attribute value does exist in a storage' do
      before { subject.write(ApiCachedAttributes::StorageEntry.new({}, 'hi')) }

      it 'returns a populated storage_entry' do
        expect(subject.storage_entry).to be_a ApiCachedAttributes::StorageEntry
      end
    end
  end

  describe 'the delegated methods' do
    it 'are delegated to the storage_entry' do
      methods = %i(data? exists? expired? headers_for_validation validateable?)

      methods.each do |method|
        expect(subject.storage_entry).to receive(method)
        subject.send(method)
      end
    end
  end

  describe '#fetch' do
    it 'calls get on the AttributeHttpClient with no headers' do
      expect_any_instance_of(ApiCachedAttributes::AttributeHttpClient)
        .to receive(:get)
        .with(no_args)
        .and_return(fake_get_response)
      subject.fetch
    end

    it 'writes the response' do
      expect(subject).to receive(:write)
      subject.fetch
    end
  end

  describe '#validate' do
    it 'calls get on the AttributeHttpClient with headers for validation' do
      expect_any_instance_of(ApiCachedAttributes::AttributeHttpClient)
        .to receive(:get)
        .with(subject.headers_for_validation)
        .and_return(fake_get_response)
      subject.validate
    end

    it 'writes the response' do
      expect(subject).to receive(:write)
      subject.validate
    end

    it 'returns true for a 304 Not Modified response' do
      expect_any_instance_of(ApiCachedAttributes::AttributeHttpClient)
        .to receive(:get)
        .and_return(fake_not_modified_response)
      expect(subject.validate).to eq(true)
    end

    it 'returns false for a non 304 Not Modified response' do
      expect_any_instance_of(ApiCachedAttributes::AttributeHttpClient)
        .to receive(:get)
        .and_return(fake_get_response)
      expect(subject.validate).to eq(false)
    end
  end

  describe '#write' do
    it 'calls write_key on every configured storage' do
      ApiCachedAttributes.storages = [
        ApiCachedAttributes::Storage::Memory.new,
        ApiCachedAttributes::Storage::Memory.new
      ]
      ApiCachedAttributes.storages.each do |storage|
        expect(storage)
          .to receive(:write_key)
          .with(attribute.key.for_storage, any_args)
      end
      subject.write(ApiCachedAttributes::NullStorageEntry.new)
    end

    it 'reloads the storage_entry' do
      original_storage_entry = subject.storage_entry
      new_storage = ApiCachedAttributes::StorageEntry.new({}, {login: 'mkcode'})
      expect(subject.storage_entry).to eq(original_storage_entry)
      subject.write(new_storage)
      expect(subject.storage_entry).to_not eq(original_storage_entry)
    end
  end
end

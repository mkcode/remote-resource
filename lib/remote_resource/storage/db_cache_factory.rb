require 'remote_resource/storage/db_cache'

module RemoteResource
  class UnsupportedDatabase < StandardError; end

  class DBCacheFactory
    def initialize(base_class, options)
      @base_class = base_class
      @options = options
    end

    def create_for_class(target_class)
      db_cache_adapter = db_cache_adapter_for(target_class)
      if db_cache_adapter
        column_name = @options[:cache_column] ||
                      default_or_magic_column_name_for(@base_class)
        DBCache.new(db_cache_adapter, column_name)
      else
        fail UnsupportedDatabase
      end
    end

    private

    def default_or_magic_column_name_for(base_class)
      "#{base_class.underscore}_cache"
    end

    def db_cache_adapter_for(klass)
      DBCache::ADAPTERS.detect do |adapter_name|
        klass.ancestors.any? do |parent_class|
          next unless (class_name = parent_class.name)
          class_name.split('::').first.underscore.to_sym == adapter_name
        end
      end
    end
  end
end

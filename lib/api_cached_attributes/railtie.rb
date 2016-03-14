module ApiCachedAttributes
  class Railtie < Rails::Railtie
    ns = 'api_cached_attributes'

    console do |app|
      ApiCachedAttributes.logger = Rails.logger
    end

    initializer "#{ns}.logger", after: 'active_record.logger' do
      ApiCachedAttributes.logger = Rails.logger
    end

    initializer "#{ns}.extend_active_record", after: 'active_record.set_configs' do |app|
      ActiveRecord::Base.send(:extend, ApiCachedAttributes::Bridge)
    end

    initializer "#{ns}.add_to_eager_load_paths" do |app|
      app.config.paths.add 'app/api_attributes', eager_load: true
    end
  end
end

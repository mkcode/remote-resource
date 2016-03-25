module RemoteResource
  class Railtie < Rails::Railtie
    ns = 'remote_resource'

    console do
      RemoteResource.logger = Rails.logger
    end

    initializer "#{ns}.logger", after: 'active_record.logger' do
      RemoteResource.logger = Rails.logger
    end

    initializer "#{ns}.extend_active_record", after: 'active_record.set_configs' do
      ActiveRecord::Base.send(:extend, RemoteResource::Bridge)
    end

    initializer "#{ns}.add_to_eager_load_paths" do |app|
      app.config.paths.add 'app/api_attributes', eager_load: true
    end
  end
end

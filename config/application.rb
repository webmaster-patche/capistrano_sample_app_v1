require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CapistranoSampleAppV1
  class Application < Rails::Application
    # MVVM api application only 20191015
    config.api_only = true

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Don't generate system test files.
    config.generators.system_tests = nil

    # Permit cross origin
    # 
    if defined?(Rack::Cors)
        config.middleware.insert_before 0, Rack::Cors do
          allow do
            origins "*"
            resource "*",
              headers: :any,
              methods: [:get, :post, :options, :head]
          end
        end
    end

    # Stackdriver Shared parameters
    # config.google_cloud.project_id = "YOUR-PROJECT-ID"
    # config.google_cloud.keyfile    = "/path/to/service-account.json"

    app_name = app_name = Rails.root.to_s.gsub(/.*\//, "")
    if ENV['RAILS_LOG_TO_STDOUT'].present? && ENV['STACKDRIVER_LOGGING_MODE'] == 'agent'
      logger           = ActiveSupport::Logger.new(STDOUT)
      logger.formatter = proc do |severity, time, progname, msg|
        request_id = msg.match(/\[(.*?)\].*/)[1] rescue ''
        entry = {
          severity: severity,
          progname: app_name.present? ?  app_name : 'rails',
          request_id: request_id,
          time: time,
          message: msg,
        }
        "#{entry.to_json}\n"
      end
      config.logger    = ActiveSupport::TaggedLogging.new(logger)
      config.colorize_logging = false
    elsif ENV['RAILS_LOG_TO_STDOUT'].present?
      logger           = ActiveSupport::Logger.new(STDOUT)
      logger.formatter = eval Settings.logger.formatter
      config.logger    = ActiveSupport::TaggedLogging.new(logger)
      config.colorize_logging = false
    else
      logger           = Logger.new("#{Rails.root}/log/#{Rails.env}.log")
      # default configure .. 
      logger.formatter = eval Settings.logger.formatter
      config.logger    = ActiveSupport::TaggedLogging.new(logger)
      config.colorize_logging = false
    end
  end
end

if ENV['STACKDRIVER_LOGGING_MODE'].present? && ENV['STACKDRIVER_LOGGING_MODE'] == 'library'
  # Stackdriver logging settings
  require "google/cloud/logging"
  Google::Cloud.configure do |config|
    # Stackdriver Logging specific parameters
    config.logging.project_id = "YOUR-PROJECT-ID"
    config.logging.keyfile    = "/path/to/service-account.json"
  end
end
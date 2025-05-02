require_relative 'boot'

require 'logger' # <-- Add this early
require 'rails'
require 'active_support/railties'

Bundler.require(*Rails.groups)

module RailsService
  class Application < Rails::Application
    config.load_defaults 7.0
    config.api_only = true
  end
end

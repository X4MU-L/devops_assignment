ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup'
require 'logger' # Explicitly require Ruby's Logger
Bundler.require(:default, ENV.fetch('RAILS_ENV', 'development'))

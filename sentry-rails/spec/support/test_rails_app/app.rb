require 'rails'
# require "active_record/railtie"
require "action_view/railtie"
require "action_controller/railtie"
# require "action_mailer/railtie"
require "active_job/railtie"
# require "action_cable/engine"
# require "sprockets/railtie"
# require "rails/test_unit/railtie"
require 'sentry/rails'

ActiveSupport::Deprecation.silenced = true

class TestApp < Rails::Application
end

class HelloController < ActionController::Base
  def exception
    raise "An unhandled exception!"
  end

  def view_exception
    render inline: "<%= foo %>"
  end

  def world
    render :plain => "Hello World!"
  end

  def not_found
    raise ActionController::BadRequest
  end
end

def make_basic_app
  app = Class.new(TestApp) do
    def self.name
      "RailsTestApp"
    end
  end

  app.config.hosts = nil
  app.config.secret_key_base = "test"

  # Usually set for us in production.rb
  app.config.eager_load = true
  app.routes.append do
    get "/exception", :to => "hello#exception"
    get "/view_exception", :to => "hello#view_exception"
    get "/not_found", :to => "hello#not_found"
    root :to => "hello#world"
  end

  app.initializer :configure_release do
    ENV["SENTRY_DSN"] = nil

    Sentry.init do |config|
      config.release = 'beta'
      config.dsn = DUMMY_DSN
      # for speeding up request specs
      config.rails.report_rescued_exceptions = false
      config.transport.transport_class = Sentry::DummyTransport
      yield(config) if block_given?
    end
  end

  app.initialize!

  Rails.application = app
  app
end

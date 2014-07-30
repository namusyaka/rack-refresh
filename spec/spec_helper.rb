require File.expand_path("../../lib/rack/refresh", __FILE__)
require 'bundler' unless defined?(Bundler)
Bundler.require(:test)

RSpec.configure do |config|
  config.include Rack::Test::Methods
end

def app
  @app
end

def mock_app(&block)
  @app = Rack::Builder.new(&block)
end

class TestApp
  def call(env)
    [200, {"Content-Type" => "text/plain"}, ["test app"]]
  end
end

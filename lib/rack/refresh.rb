require 'rack/refresh/version'

module Rack
  class Refresh
    def initialize(app, url: nil, interval: 0, **options, &block)
      @app      = app
      @url      = url
      @interval = interval
      instance_eval(&block) if block_given?
    end

    def call(env)
      dup._call(env)
    end

    def _call(env)
      response = @app.call(env)
      route = find_refresh_route_from(env)
      refresh_for(response, route[:interval], route[:url]) if route
      response
    end

    def refresh(path = nil, interval: nil, url: nil, &matcher)
      current_route = {interval: interval || @interval, url: url || @url}
      raise ArgumentError, "`:url` must be set in refresh" unless current_route[:url]
      return unless path || block_given?
      current_route[:path] = path
      current_route[:matcher] = matcher
      routes << current_route
    end

    def refresh_for(response, interval, url)
      response[1]["Refresh"] = "#{interval}; url=#{url}"
    end

    def find_refresh_route_from(env)
      path_info = env["PATH_INFO"]
      routes.find{|route| route[:path] ? (route[:path] === path_info) : route[:matcher].call(env) }
    end

    def routes
      @routes ||= []
    end

    private :find_refresh_route_from, :routes, :refresh_for
  end
end

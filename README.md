# Rack::Refresh

Rack Middleware for adding `Refresh` field to response headers.

**`Refresh` is supported by modern browsers, but it isn't official HTTP standard.
So please be careful when using this.**

## Installation

Add this line to your application's Gemfile:

    gem 'rack-refresh'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-refresh

## Usage

`Rack::Refresh` is easy to use.
I would explain how to use it in three sections.

```ruby
use Rack::Refresh do
  refresh "/", interval: 5, url: "http://www.google.com/"
  refresh do |env|
    env["PATH_INFO"] == "/path" && env["REQUEST_METHOD"].to_s.upcase == "GET"
  end
  refresh %r{/hello.+?} do |env|
    env["PATH_INFO"].start_with?("/hello")
  end
end
```

### with Path

The path can be set string and regex.
The refresh field will be added to response headers if the path matches with `ENV["PATH_INFO"]`

```ruby
use Rack::Refresh do
  # String
  refresh "/", url: "http://www.google.com/"
  # Regex
  refresh %r{/foo}, url: "http://www.google.com/"
end
```

### with Block

The refresh field will be added to response headers if the return value of block is `true`.

```ruby
use Rack::Refresh do
  refresh do |env|
    env["PATH_INFO"].start_with?("/hello")
  end
end
```

### Configuration

`:url` and `:interval` can be set in `refresh` and `use` methods.
If options are set in both methods, `refresh`'s option will be priority.

```ruby
use Rack::Refresh, url: "http://www.google.com/", interval: 5 do
  refresh "/" #=> Refresh: 5; url=http://www.google.com/
  refresh "/foo", url: "http://namusyaka.info/", interval: 0 #=> Refresh: 0; url=http://namusyaka.info/
end
```

## Contributing

1. Fork it ( https://github.com/namusyaka/rack-refresh/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

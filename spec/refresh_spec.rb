require 'spec_helper'

describe Rack::Refresh do
  context "with path" do
    before do
      mock_app do
        use Rack::Refresh do
          refresh "/", url: "https://www.google.co.jp/"
          refresh "/some", url: "https://www.google.co.jp/some", interval: 5
          refresh %r{\A/archives/\d+\z}, url: "http://namusyaka.info/"
        end
        run TestApp.new
      end
    end

    it "can be set path as the condition for refreshing response" do
      get "/"
      expect(last_response.headers["Refresh"]).to eq("0; url=https://www.google.co.jp/")
      get "/some"
      expect(last_response.headers["Refresh"]).to eq("5; url=https://www.google.co.jp/some")
    end

    it "can be set path as the condition for refreshing response if path is an instance of regexp" do
      get "/archives/1234"
      expect(last_response.headers["Refresh"]).to eq("0; url=http://namusyaka.info/")
    end

    it "should not refresh response if the path is not matched with env['PATH_INFO']" do
      get "/hello_world"
      expect(last_response.headers["Refresh"]).to be_nil
    end
  end

  context "with block" do
    before do
      mock_app do
        use Rack::Refresh do
          refresh url: "https://www.google.co.jp/" do |env|
            env["PATH_INFO"].start_with?("/hello")
          end
        end
        run TestApp.new
      end
    end

    it "can be set block as the condition for refreshing response" do
      get "/hello"
      expect(last_response.headers["Refresh"]).to eq("0; url=https://www.google.co.jp/")
    end

    it "should not refresh response if the return value of block is false" do
      get "/hell_world"
      expect(last_response.headers["Refresh"]).to be_nil
    end
  end

  context "with parent options" do
    before do
      mock_app do
        use Rack::Refresh, url: "https://www.google.co.jp/", interval: 5 do
          refresh "/"
          refresh %r{/\d+}, url: "http://namusyaka.info/", interval: 3
        end
        run TestApp.new
      end
    end

    it "can be set options as the default condition for refreshing response" do
      get "/"
      expect(last_response.headers["Refresh"]).to eq("5; url=https://www.google.co.jp/")
    end

    it "can override the parent options by setting refresh options" do
      get "/1234"
      expect(last_response.headers["Refresh"]).to eq("3; url=http://namusyaka.info/")
    end
  end

  describe "exception" do
    it "should raise ArgumentError if :url is not set in refresh method" do
      expect { Rack::Refresh.new{ refresh "/" }}.to raise_error(ArgumentError)
    end

    it "should not raise ArgumentError if :url is set as the parent options" do
      expect { Rack::Refresh.new(nil, url: "https://www.google.co.jp/"){ refresh "/" }}.to_not raise_error
    end
  end
end

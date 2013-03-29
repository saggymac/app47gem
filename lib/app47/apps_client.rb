require 'rest-client'
require 'json'
require 'app47/client.rb'


module App47


  class AppsClient < Client

    def initialize
      super()
    end

    # list the apps for a given account
    def read
      path = '/api/apps'
      url = @app_url + path

      begin
        response = RestClient.get url, { 'X-Token' => @api_token, :accept => :json}
      rescue => err
        raise RuntimeError.new( "HTTP connection error: #{err.message}")
      end

      jobj = nil

      if [200].include? response.code
        jobj = JSON.parse( response.body.to_s)
      else
        raise RuntimeError.new( "Invalid response: #{response.code.to_s}")
      end

      jobj
    end


  end

end

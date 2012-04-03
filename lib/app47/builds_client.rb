require 'rest-client'
require 'json'
require 'app47/client.rb'


module App47

  # Valid values: ':ios', ':android'
  module BuildPlatform
    # Get the string value expected by the App47 REST API for the various platform symbols
    # @param [Symbol] a platform symbol {include:BuildPlatform}
    # @return [String] the json string value for the given symbol, or empty string
    def to_json( bp )
      return "iOS" if bp == :ios
      return "Android" if bp == :android
      ""
    end
  end



  #
  # This class wraps the CRUD methods for dealing with builds for a given app.
  # @example Create a client, then use it
  #   client = App47BuildClient.new( 'your-api-token', 'an-app-id', :ios)
  #   client.read 
  #
  class BuildsClient < Client

    attr_accessor :appId, :platform

    # @param [String] apiToken your App47 api token
    # @param [String] appId the application on which you will be referencing builds
    # @param [Symbol] platform this app's platform (see {BuildPlatform}) 
    def initialize( appId, platform = :ios)
      @appId = appId
      @platform = BuildPlatform.to_json( platform)
    end


    # Creates a new build for the specified appId 
    # @param  [File] file The .ipa build file for ios, or .apk for android
    # @param [String] releaseNotes A blurb describing the bulid; not meant to be too long
    # @param [Boolean] makeActive Indicates whether or not the build should be made the active build or not
    # @return [JSON] returns a json build object on success, or nil on error
    def create ( file, releaseNotes, makeActive=false )
      fileName = File.basename( file.path)

      build_doc = {
        :build => {
          :platform => @platform,
          :environment => "Test", # TODO: doesn't matter for iOS, but will for Android'
          :upload => file,
          :build_file => fileName,
          :release_notes => (releaseNotes!=nil) ? releaseNotes : '',
          :active => makeActive }
        }

        begin
          response = RestClient.post @options[:apiHost] + "/api/apps/#{@appId}/builds",  build_doc, {'X-Token' => @apiToken, :accept => :json}
        rescue => err
          raise RuntimeError.new( "HTTP connection error: #{err.message}")
        end

        if [200, 201, 202].include? response.code
          jobj = JSON.parse( response.body.to_s)
        else
          raise RuntimeError.new( "Invalid response: #{response.code.to_s}")
          nil
        end
    end


    # Read a list of builds for the current appId, or a specified build.
    # @param [String] buildId An optional buildId, when specified this method just fetches the specified build.
    # @return [JSON] Returns a json array of builds, a json build, or nil if error
    def read ( buildId=nil )
      path = "/api/apps/#{appId}/builds"
      path = path << "/#{buildId}" if buildId != nil

      url = @options[:apiHost] + path

      begin
        response = RestClient.get url, { 'X-Token' => @apiToken, :accept => :json}
      rescue => err
        raise RuntimeError.new( "HTTP connection error: #{err.message}")
      end

      if [200].include? response.code
        jobj = JSON.parse( response.body.to_s)
      else
        raise RuntimeError.new( "Invalid response: #{response.code.to_s}")
      end

    end

    # Not implemented yet
    def update ( buildId, buildObj )
      raise NotImplementedError
    end

    # Not implemented yet  
    def delete ( buildId )
      raise NotImplementedError      
    end
  end

end

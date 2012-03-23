require 'rest-client'
require 'json'

$app_url = "https://cirrus.app47.com"

# Valid values: ':ios', ':android'
module BuildPlatform
  :ios
  :android
  
  # Get the string value expected by the App47 REST API for the various platform symbols
  # @param [Symbol] a platform symbol {include:BuildPlatform}
  # @return [String] the json string value for the given symbol, or empty string
  def to_json( bp )
    return "iOS" if bp == :ios
    return "Android" if bp == :android
    return ""
  end
end



#
# This class wraps the CRUD methods for dealing with builds for a given app.
# @example Create a client, then use it
#   client = App47BuildClient.new( 'your-api-tokan', 'an-app-id', :ios)
#   client.read 
#
class App47BuildClient
  
  attr_accessor :apiToken, :appId, :platform
  
  # @param [String] apiToken your App47 api token
  # @param [String] appId the application on which you will be referencing builds
  # @param [Symbol] platform this app's platform (see {BuildPlatform}) 
  def initialize( apiToken, appId, platform = :ios)
    @apiToken = apiToken
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
       :environment => "Test", # Doesn't matter for iOS'
       :upload => file,
       :build_file => fileName,
       :release_notes => releaseNotes,
       :active => makeActive }
    }

    response = RestClient.post $app_url + "/api/apps/#{@appId}/builds",
            build_doc,
            {"X-Token" => @apiToken, :accept => :json}

    if ! [200, 201, 202].include? response.code
            $stdout.puts( "There was a problem uploading the build: code " + response.code.to_s)
            return nil
    else
            jobj = JSON.parse( response.body.to_s)
            return jobj
#            $stdout.puts( JSON.pretty_generate( jobj))
    end    
  end
  
  
  # Read a list of builds for the current appId, or a specified build.
  # @param [String] buildId An optional buildId, when specified this method just fetches the specified build.
  # @return [JSON] Returns a json array of builds, a json build, or nil if error
  def read ( buildId=nil )
    path = "/api/apps/#{appId}/builds";
    path = path << "/#{buildId}" if buildId != nil
    
    url = $app_url + path
    #puts "GET: #{url}"
    
    response = RestClient.get url,
            {"X-Token" => @apiToken, :accept => :json}

    if ! [200].include? response.code
            $stdout.puts( "There was a problem accessing the builds: code " + response.code.to_s)
            return nil
    else
            jobj = JSON.parse( response.body.to_s)
            #$stdout.puts( JSON.pretty_generate( jobj))            
            return jobj
    end
    
  end
  
  # Not implemented yet
  def update ( buildId, buildObj )
  end
  
  # Not implemented yet  
  def delete ( buildId )
  end
end

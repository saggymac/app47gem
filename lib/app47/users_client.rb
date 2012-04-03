require 'rest-client'
require 'json'
require 'app47/client.rb'
require 'roo'

module App47

  class User
    attr_accessor :name, :email, :auto_approve

    def initialize(name, email, auto_approve)
      @name = name
      @email = email
      @auto_approve = auto_approve
    end

    def to_s
      "#{name} #{email} #{auto_approve}"
    end

  end



  #
  #
  #
  class UsersClient < Client



    #
    def initialize(  )
           super()
    end



    def parse ( bulk_file )
      users = []
      sheet = Excel.new( bulk_file)
      sheet.default_sheet = sheet.sheets.first
      2.upto(sheet.last_row) do |row|
        users << User.new(sheet.cell(row, 'A'), sheet.cell(row, 'B'), sheet.cell(row, 'C'))
      end

      users
    end


    #
    # @param [User] user create a new user
    # @return [JSON] returns the newly created JSON object on success, nil on error
    #
    def create ( user )

      return unless user.instance_of? App47::User

      url = @options[:apiHost] + "/api/users"

      json = { :user => { :name => user.name, :email => user.email, :auto_approved => user.auto_approve }}.to_json

      response = RestClient.post url, json, {"X-Token"=> @api_token, :accept => :json, :content_type => :json}

      json_obj = nil

      if response.code == 201
        json_obj = JSON.parse( response.body.to_s)
      else
        puts "There was an error creating #{user.name}'s record in the App47 system. The response from App47 is: "
        puts response.to_s
      end

      json_obj
    end


    #
    # @param [File] bulk_file the spreadsheet file to parse, and send up to the server
    # @return [UsersClient] returns self
    #
    def bulk_upload( bulk_file )

      users = parse bulk_file

      return if users == nil
      return if users.count <= 0

      users.each do | user |
        create user
      end

      self
    end


    #
    # Read users from the API
    # @param [String] user_id an optional user_id string identifying the user to read; if not present
    #  this method reads all the users from the account
    # @return [JSON] the JSON response object on success; nil on error
    def read ( user_id = nil )

      url = @app_url + "/api/users"
      url = url << "/#{user_id}" unless user_id == nil

      response = RestClient.get url, {"X-Token"=> @api_token, :accept => :json}

      json_obj = nil

      if response.code == 200
        json_obj = JSON.parse( response.body.to_s)
      else
        raise RuntimeError.new( "Invalid response: #{response.code.to_s}")
      end

      json_obj
    end


  end

end

require 'rest-client'
require 'json'
require 'app47/client.rb'
require 'roo'

unless defined?( CSV)
  require 'fastercsv'
end


module App47

  class User
    attr_accessor :name, :email, :auto_approve, :group_ids

    def initialize(name, email, auto_approve)
      @name = name
      @email = email
      @auto_approve = auto_approve
      @group_ids = []
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
    def initialize()
      super()
    end


    # @param [String] bulk_file the path to a CSV file
    # @return [Array] returns an array of User objects
    def parse_csv(bulk_file)
      users = []

      if defined?( CSV)
        clss = CSV
      else
        clss = FasterCSV
      end

      clss.foreach(bulk_file) do |row|
        name = row[0]
        email = row[1]
        auto = row[2]

        name = name.strip unless name.nil?
        email = email.strip unless email.nil?
        auto = auto.strip unless auto.nil?

        users << User.new( name, email, auto)
      end

      users
    end


    def parse (bulk_file)
      sheet = nil
      users = []

      ext = File.extname(bulk_file)

      case ext
        when ".xls"
          sheet = Excel.new(bulk_file)

        when ".xlsx"
          sheet = Excelx.new(bulk_file)

        when ".ods"
          sheet = Openoffice.new(bulk_file)

        when ".csv"
          users = parse_csv(bulk_file)

        else
          raise RuntimeError.new("#{ext} is not an extention type we can handle")
      end

      unless sheet.nil?
        sheet.default_sheet = sheet.sheets.first
        2.upto(sheet.last_row) do |row|
          users << User.new(sheet.cell(row, 1), sheet.cell(row, 2), sheet.cell(row, 3))
        end
      end

      users
    end


    #
    # @param [User] user create a new user
    # @return [JSON] returns the newly created JSON object on success, nil on error
    #
    def create (user)

      return unless user.instance_of? App47::User

      url = @app_url + "/api/users"

      json_obj = {:name => user.name, :email => user.email, :auto_approved => user.auto_approve}
      unless user.group_ids.empty?
        json_obj[:group_ids] = user.group_ids
      end

      json = {:user => json_obj}.to_json

      begin
        response = RestClient.post url, json, {"X-Token" => @api_token, :accept => :json, :content_type => :json}
      rescue => e
        raise RuntimeError.new("Error response: #{e.response.code.to_s}: #{e.response}")
      end

      json_obj = nil

      if response.code == 201
        json_obj = JSON.parse(response.body.to_s)
      else
        puts "There was an error creating #{user.name}'s record in the App47 system. The response from App47 is: "
        puts response.to_s
      end

      json_obj
    end


    #
    # The spreadsheet has a few requirements. At present, it supports three columns, in this order:
    #  1) user name
    #  2) email
    #  3) auto approve (device registrations)
    #
    #  Same is true regardless of whether you are using a CSV, .xls, .xlsx, or otherwise.
    #
    # @param [File] bulk_file the spreadsheet file to parse, and send up to the server
    # @return [UsersClient] returns self
    #
    def bulk_upload(bulk_file, group_ids=nil)

      users = parse bulk_file

      return if users == nil
      return if users.count <= 0

      users.each do |user|
        user.group_ids = group_ids unless group_ids.nil?

        create user
      end

      self
    end


    #
    # Read users from the API
    # @param [String] user_id an optional user_id string identifying the user to read; if not present
    #  this method reads all the users from the account
    # @return [JSON] the JSON response object on success; nil on error
    def read (user_id = nil)

      url = @app_url + "/api/users"
      url = url << "/#{user_id}" unless user_id == nil

      response = RestClient.get url, {"X-Token" => @api_token, :accept => :json}

      json_obj = nil

      if response.code == 200
        json_obj = JSON.parse(response.body.to_s)
      else
        raise RuntimeError.new("Invalid response: #{response.code.to_s}")
      end

      json_obj
    end


  end

end

require 'rest-client'
require 'json'
require 'app47/client.rb'


#
# http://app47.com/wiki/doku.php?id=account_mgmt_api:groups
#
# Required parameter: name Optional parameters: descritpion, app_ids
#
# The only required attribute is a Group's name. You can optionally specify a list of App ID's
# for which this group as rights to. A optional description can also be given to a Group.
#


module App47

  class Group
    attr_accessor :id, :name, :app_ids, :descrption

    def initialize(name, description=nil)
      @id = nil # server owned
      @name = name
      @description = description
      @app_ids = []
    end

    def to_s
      "#{name} (#{id})"
    end


  end


  #
  #
  #
  class GroupsClient < Client


    #
    def initialize()
      super()
    end


    #
    # @param [Group] group create a new group
    # @return [JSON] returns the newly created JSON object on success, nil on error
    #
    def create (group)

      url = @app_url + "/api/groups"

      group_obj = {:name => group.name}
      group_obj[:descrption] = group.description unless group.description.nil?
      group_obj[:app_ids] = group.app_ids unless group.app_ids.nil? && group.app_ids.count <= 0


      json = {:group => group_obj}.to_json
      response = RestClient.post url, json, {"X-Token" => @api_token, :accept => :json, :content_type => :json}

      json_obj = nil

      if response.code == 201
        json_obj = JSON.parse(response.body.to_s)
      else
        puts "There was an error creating #{group_name}'s record in the App47 system. The response from App47 is: "
        puts response.to_s
      end

      json_obj
    end


    def find_group_by_name(group_name_to_match)

      return nil if group_name_to_match.nil?

      groups_json = read
      return nil if groups_json.nil?

      matched_group = nil
      groups_json.each do |group|
        group_name = group["name"]

        if group_name
          m = group_name.match(/#{group_name_to_match}/)
          matched_group = group if m[0] == group_name_to_match
        end
      end

      matched_group
    end


    #
    # Read groups from the API
    # @param [String] group_id an optional group_id string identifying the group to read; if not present
    #  this method reads all the groups from the account
    # @return [JSON] the JSON response object on success; nil on error
    def read (group_id = nil)

      url = @app_url + "/api/groups"
      url = url << "/#{group_id}" unless group_id == nil

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

require 'optparse'
require 'app47/cli/command.rb'
require 'app47/cli/usage_error.rb'
require 'app47/groups_client.rb'
require 'app47/cli/json_helpers.rb'

module App47
  module CLI

    #
    # Expected usage is:
    #
    # A bulk upload:
    # app47 groups create
    #
    # Read one or all users:
    # app47 groups read
    #
    # Find a group by name:
    # app47 groups find -n group_name
    #
    class Groups < Command

      # @param [OptionParser] op
      def define_opts( op )
        super( op)

        op.on( '-nMANDATORY', '--name=MANDATORY', 'group name for the new being created') { |name|
          @options[:name] = name
        }

        op.on( '-gMANDATORY', '--group=MANDATORY', 'group ID for the user being created; required for reading a specific group') { |group_id|
          @options[:groupId] = group_id
        }

        op.on( '-dMANDATORY', '--description=MANDATORY', 'an optional description for the group') { |desc|
          @options[:description] = desc
        }


      end

      def initialize
        super

        @command = :unknown
      end


      # @throws [UsageError] if there is an error with the parameters
      def groups_validate
        validate() # call the super, to validate generic args

        if @command == :read
          gid = @options[:groupId]
          raise UsageError.new('invalid group id') if gid && gid.length <= 0
        end

        if @command == :create

          # required values are name. but can add description.

          name = @options[:name]
          raise UsageError.new("you must specify a name to create a new group") if name.nil?

        end

        if @command == :find

          # required values are name. but can add description.

          name = @options[:name]
          raise UsageError.new("you must specify the name of a group to find") if name.nil?

        end

      end



      # This can read in two modes: all users for an account, or a single group specified by group ID
      def read ()
        groups_validate

        gid = @options[:groupId]

        client = GroupsClient.new
        client.api_token = @options[:apiKey]
        client.app_url = @options[:apiHost]


        resp = client.read( gid)
        print_json resp
      end


      def find ()
        groups_validate

        group_name = @options[:name]

        client = GroupsClient.new
        client.api_token = @options[:apiKey]
        client.app_url = @options[:apiHost]


        resp = client.find_group_by_name( group_name)
        print_json resp
      end


      5
      
      def create ()
        groups_validate
        
        client = GroupsClient.new
        client.api_token = @options[:apiKey]
        client.app_url = @options[:apiHost]

        group = App47::Group.new(@options[:name], @options[:description])

        client.create(group)

      end


      def run ( *args )
        op = OptionParser.new
        define_opts( op)
        op.parse( *args)
        
        handled = false
        
        unless @options[:help]
          if args && args.count > 0
            cmd = args.first.to_sym
            if self.respond_to? cmd
              handled = true
              @command = cmd
              handler = method( cmd)
              handler.call()
            end
          end
        end
        
        if @options[:help] || !handled
          puts "Usage: app47 groups subcmd [options]"
          puts "Sub commands: create read find"
          puts ""
          puts "EXAMPLES"
          puts ""
          puts "Reading the list of groups, or a single group for an account:"
          puts "  app47 groups read -k <apiKey> [-g groupId]"
          puts ""          
          puts "Creating a new group:"
          puts "  app47 groups create -k <apiKey> -n <name> [-d <description>]"
          puts ""
          puts "Find a group by name:"
          puts "  app47 groups find -k <apiKey> -n <name>"
        else                
          puts op.help unless handled
        end

      end

    end
    
  end
end

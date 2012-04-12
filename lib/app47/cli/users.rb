require 'optparse'
require 'app47/cli/command.rb'
require 'app47/cli/usage_error.rb'
require 'app47/users_client.rb'
require 'app47/groups_client.rb'
require 'json'
require 'app47/cli/json_helpers.rb'


module App47
  module CLI

    #
    # Expected usage is:
    #
    # A bulk upload:
    # app47 users create (-f bulkFile | -u userName -e email --autoAccept )
    #
    # Read one or all users:
    # app47 users read [-u userId]
    #
    class Users < Command

      # @param [OptionParser] op
      def define_opts( op )
        super( op)

        op.on( '-fMANDATORY', '--file=MANDATORY', 'path to the bulk file (spreadsheet)') { |bulk_file|
          @options[:bulkFile] = bulk_file
        }

        @options[:autoApprove] = false
        op.on( '--autoAccept', 'auto accept device identifiers (default:no)') {
          @options[:autoApprove] = true
        }

        op.on( '-eMANDATORY', '--email=MANDATORY', 'email for the user being created') { |email|
          @options[:email] = email
        }

        op.on( '-nMANDATORY', '--name=MANDATORY', 'user name for the user being created') { |username|
          @options[:userName] = username
        }

        op.on( '-uMANDATORY', '--user=MANDATORY', 'the user id for the user to act on') { |user_id|
          @options[:userId] = user_id
        }

        op.on( '-gMANDATORY', '--groups=MANDATORY', 'a semicolon separated list of group names to be assigned to the user') { |groups|
          @options[:groups] = groups
        }


      end

      def initialize
        super

        @command = :unknown
      end


      # @throws [UsageError] if there is an error with the parameters
      def users_validate
        validate() # call the super, to validate generic args


        if @command == :read
          uid = @options[:userId]
          raise UsageError.new('invalid user id') if uid && uid.length <= 0
        end

        if @command == :create

          filename = @options[:bulkFile]

          if filename.nil?
            # If no filename, must have user and email
            user = @options[:userName]
            raise UsageError.new( "no user name provided") if user.nil?
            
            email = @options[:email]
            raise UsageError.new( "no email address provided") if email.nil?

          else
            raise UsageError.new( "bulk file does not exist: #{filename}") unless File.exists?( filename)
          end


          # Validate the groups list, if present
          groups_param = @options[:groups]
          unless groups_param.nil?
            groups = groups_param.split( ';')
            if groups.nil? || groups.count <= 0
              raise UsageError.new( "invalid groups specification; should be a non-emtpy semicolon separated list of group names")
            end
          end

        end

      end



      # This can read in two modes: all users for an account, or a single user specified by user ID
      def read ()
        users_validate

        uid = @options[:userId]

        client = UsersClient.new
        client.api_token = @options[:apiKey]
        client.app_url = @options[:apiHost]


        resp = client.read( uid)
        print_json resp
      end


      # Lookup the groups matching the list of patterns. And then give the user
      # a chance to review those matches. If they approve, return the list of associated
      # group IDs. If not, return nil.
      #
      # @param group_patterns [Array] an array of simple group name patterns
      # @return [Array] returns the array of matched and approved group IDs. If the user does not approve
      #   or there was an error, we return nothing.
      def lookup_and_approve_groups( group_patterns )
        return nil if group_patterns.nil?
        return nil if group_patterns.empty?

        groups_client = GroupsClient.new
        groups_client.api_token = @options[:apiKey]
        groups_client.app_url = @options[:apiHost]

        matched_groups = groups_client.determine_group_ids( group_patterns)

        group_ids = []

        if matched_groups.nil? || matched_groups.empty?
          puts "No groups matched"
        else

          group_names = []
          matched_groups.each do |group|
            group_names.push(group["name"])
          end

          puts "Please review the matched groups: " + group_names.join( ', ')
          puts "Continue? (y/n)"

          response = STDIN.gets.chomp

          if response[0].downcase == 'y'
            matched_groups.each do |group|
              group_ids.push(group["_id"])
            end
          end

        end

        group_ids
      end


      
      def create ()
        users_validate
        
        client = UsersClient.new
        client.api_token = @options[:apiKey]
        client.app_url = @options[:apiHost]
        
        filename = @options[:bulkFile]

        groups_param = @options[:groups]
        if groups_param.nil?
          approved_group_ids = nil
        else
          approved_group_ids = lookup_and_approve_groups( groups_param.split(';'))
        end


        if filename.nil?
          user = App47::User.new( @options[:userName], @options[:email], @options[:autoApprove])

          unless approved_group_ids.nil?
            user.group_ids = approved_group_ids
          end

          client.create( user)
          
        else
          client.bulk_upload( filename, approved_group_ids)
        end

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
          puts "Usage: app47 users subcmd [options]"
          puts "Sub commands: create read"
          puts ""
          puts "EXAMPLES"
          puts ""
          puts "Reading the list of users, or a single user for an account:"
          puts "  app47 users read -k <apiKey> [-u userId]"
          puts ""          
          puts "Creating a new user (single, or bulk through a file:"
          puts "  app47 users create -k <apiKey> (-f <bulkFile> | -u <userName> -e <email> [--autoAccept]) [--groups=]"
        else                
          puts op.help unless handled
        end

      end

    end
    
  end
end

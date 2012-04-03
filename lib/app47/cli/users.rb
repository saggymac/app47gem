require 'optparse'
require 'app47/cli/command.rb'
require 'app47/cli/usage_error.rb'
require 'app47/users_client.rb'
require 'json'

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

        op.on( '-fMANDATORY', '--file=MANDATORY', 'path to the bulk file (spreadsheet)') { |bulkFile|
          @options[:bulkFile] = bulkFile
        }

        @options[:active] = false
        op.on( '--autoAccept', 'auto accept device identifiers (default:no)') {
          @options[:active] = true
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

          if filename == nil

            #TODO: validate the other params

          else
            raise UsageError.new( 'missing bulk file parameter') if filename == nil
            raise UsageError.new( "bulk file does not exist: #{filename}") unless File.exists?( filename)
          end

        end

      end

      # A helper shortcut for printing json strings
      # @param [JSON] a parsed json object to display/print
      # @return [void]
      def print_json(json_obj)
        puts JSON.pretty_generate( json_obj)
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
          puts "  app47 users create -k <apiKey> (-f <bulkFile> | -u <userName> -e <email> [--autoAccept])"
        else                
          puts op.help unless handled
        end

      end

    end
    
  end
end

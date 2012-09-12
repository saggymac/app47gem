require 'optparse'
require 'app47/cli/command.rb'
require 'app47/cli/usage_error.rb'
require 'app47/builds_client.rb'
require 'json'

module App47
  module CLI

    #
    # Expected usage is:
    # app47 builds create -a appId -f ipaFile -v buildVersion [-n releaseNotes] [--makeActive]
    # app47 builds read [-b buildId]
    #
    class Builds < Command

      # @param [OptionParser] op
      def define_opts( op )
        super( op)

        op.on( '-aMANDATORY', '--appId=MANDATORY', 'application identifier') { |appId|
          @options[:appId] = appId
        }
        
        op.on( '-fMANDATORY', '--file=MANDATORY', 'path to the build file') { |buildFilePath|
          @options[:buildFile] = buildFilePath
        }
        
        op.on( '-VMANDATORY', '--buildVersion=MANDATORY', 'this build\'s version') { |vers|
          @options[:version] = vers
        }
        
        op.on( '-nMANDATORY', '--notes=MANDATORY', 'release notes') { |notes|
          @options[:notes] = notes
        }

        @options[:makeActive] = false
        op.on( '--makeActive', 'make this build active (default:no)') {
          @options[:makeActive] = true
        }

        op.on( '-pMANDATORY', '--platform=MANDATORY', 'the platform for this build (ios or android') { |platform|
          @options[:platform] = platform.downcase.to_sym
        }

        op.on( '-bMANDATORY', '--build=MANDATORY', 'build identifier') { |buildId|
          @options[:buildId] = buildId
        }

      end

      def initialize
        super

        @command = :unknown
      end


      # @throws [UsageError] if there is an error with the parameters
      def builds_validate
        validate() # call the super, to validate generic args

        app_id = @options[:appId]
        raise UsageError.new('missing app id') if app_id == nil
        raise UsageError.new('invalid app id') if app_id.length <= 0

        if @command == :read
          bid = @options[:buildId]
          raise UsageError.new('invalid build id') if bid && bid.length <= 0
        end

        if @command == :create
          platform = @options[:platform]
          # Only required if creating a build
          raise UsageError.new( 'missing platform') if platform == nil
          raise UsageError.new( 'invalid platform') if platform.length <= 0
          raise UsageError.new( 'invalid platform') unless platform == :ios || platform == :android

          filename = @options[:buildFile]
          raise UsageError.new( 'missing build file') if filename == nil
          raise UsageError.new( "file does not exist: #{filename}") unless File.exists?( filename)

          raise UsageError.new( 'missing version param') unless @options[:version] != nil
        end

      end

      # A helper shortcut for printing json strings
      # @param [JSON] a parsed json object to display/print
      # @return [void]
      def print_json(json_obj)
        puts JSON.pretty_generate( json_obj)
      end


      # This can read in two modes: all builds for an app, and a single build specified by build ID
      def read ()
        builds_validate

        bid = @options[:buildId]

        client = BuildsClient.new( @options[:appId], @options[:platform])
        client.api_token = @options[:api_token]
        client.app_url = @options[:app_url]

        resp = client.read( bid)
        print_json resp
      end

      def build_exists? (client,version)

        builds = client.read

        exists = false

        builds.each { |build|
          vers = build["version"]
          if vers == version
            exists = true
            break
          end
        }

        exists
      end

      def create
        builds_validate

        client = BuildsClient.new( @options[:appId], @options[:platform])
        client.api_token = @options[:api_token]
        client.app_url = @options[:app_url]

        vers = @options[:version]
        raise RuntimeError.new( "Version #{vers} already exists") if build_exists?( client, vers)

        file = File.new( @options[:buildFile])
        raise RuntimeError.new( 'unable to read the build file') if file == nil

        # TODO: copy in the polling logic
        resp = client.create( file, @options[:notes], @options[:makeActive], @options[:version])
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
          puts "Usage: app47 builds subcmd [options]"
          puts "Sub commands: create read"
          puts ""
          puts "EXAMPLES"
          puts ""
          puts "Reading the list of builds for an app:"
          puts "  app47 builds read -k <api_token> -a appId"
          puts ""          
          puts "Reading a specific build:"
          puts "  app47 builds read -k <api_token> -a appId -b buildId"
          puts ""          
          puts "Creating a new build (e.g., posting a build):"
          puts "  app47 builds create -k <api_token> -a appId -V vers -f buildFilePath [-n notes] [--makeActive]"
        else                
          puts op.help unless handled
        end

      end

    end
    
  end
end

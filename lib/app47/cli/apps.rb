require 'optparse'
require 'app47/cli/command.rb'
require 'app47/cli/usage_error.rb'
require 'app47/apps_client.rb'
require 'app47/cli/json_helpers.rb'

module App47

  module CLI

    #
    # Expected usage is:
    #
    # A bulk upload:
    # app47 apps list
    #
    # Read one or all users:
    # app47 apps read
    #
    class Apps < Command



      # @throws [UsageError] if there is an error with the parameters
      def apps_validate

        validate() # call the super, to validate generic args

      end



      def read
        apps_validate

        client = AppsClient.new
        client.api_token = @options[:api_token]
        client.app_url = @options[:app_url]

        resp = client.read

        print_json resp
      end



      def list
        apps_validate

        client = AppsClient.new
        client.api_token = @options[:api_token]
        client.app_url = @options[:app_url]

        resp = client.read

        # _id, instance.name
        resp.each { |app|

          id = app[ '_id']
          name = app[ 'name']

          #app_instance = app[ 'instance']
          #
          #name = 'Unknown'
          #unless app_instance.nil?
          #  name = app_instance.at(0).fetch( 'name')
          #end


          printf( '%-32s %s', id, name)
          puts ''
        }

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
          puts 'Usage: app47 apps <subcmd> [options]'
          puts 'Sub commands: read list'
          puts ''
          puts 'EXAMPLES'
          puts ''
          puts 'Reading the raw list of apps json data:'
          puts '  app47 apps read -k <api_token>'
          puts ''
          puts 'Reading a list of apps:'
          puts '  app47 apps list -k <api_token>'
        else
          puts op.help unless handled
        end

      end      
      
      
      

    end



  end


end

require 'app47/cli/usage_error.rb'
require 'yaml'

module App47
  module CLI

    # Base class for commands - allows us to define common command line parameters
    # @abstract
    class Command

      def self.run(*args) 
        new.run(*args) 
      end      


      #
      # Document this so folks know what options are supported in the RC file.
      #
      # :api_key
      # :appId
      # :app_url
      # 
      def read_rc_file
        
        file = File.join( ENV['HOME'], '.app47rc') 
        if File.exists? file 
          config_options = YAML.load_file( file) 
          @options.merge!( config_options)
        end

      end


      def initialize
        @options = {}

        @options[:app_url] = "https://cirrus.app47.com" # The default
        
        read_rc_file
      end
      

      # @param [OptionParser] op the option parser      
      def define_opts( op )
        op.banner = "Usage: app47 command [options]"
        op.separator ""
        op.separator "Valid commands:"
        op.separator "  builds"
        op.separator ""

        op.on( '-kMANDATORY', '--api_token=MANDATORY', 'your app47 api key') do |api_token|
          @options[:api_token] = api_token
        end

        op.on( '-h', '--help', 'display help') {|help|
          @options[:help] = true
        }

      end


      def validate
        k = @options[:api_token]

        raise UsageError.new("missing api key") unless k && k.length > 0
      end


    end

  end
end

require 'app47/cli/usage_error.rb'


module App47
  module CLI

    # Base class for commands - allows us to define common command line parameters
    # @abstract
    class Command

      def self.run(*args) 
        new.run(*args) 
      end      

      def initialize
        @options = {}
      end

      # @param [OptionParser] op the option parser      
      def define_opts( op )
        op.banner = "Usage: app47 command [options]"
        op.separator ""
        op.separator "Valid commands:"
        op.separator "  builds"
        op.separator ""

        op.on( '-kMANDATORY', '--apiKey=MANDATORY', 'your app47 api key') do |apiKey|
          @options[:apiKey] = apiKey
        end

        op.on( '-h', '--help', 'display help') {|help|
          @options[:help] = true
        }

      end


      def validate
        k = @options[:apiKey]

        raise UsageError.new("missing api key") unless k && k.length > 0
      end


    end

  end
end
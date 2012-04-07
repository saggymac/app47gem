require 'app47/cli/symbol_hash.rb'
require 'app47/cli/builds.rb'
require 'app47/cli/users.rb'
require 'app47/cli/usage_error.rb'

module App47
  module CLI

    class CommandLineApp
      class << self
        # @return [Hash{Symbol => Command}] the mapping of command names to
        #   command classes to parse the user command.
        attr_accessor :commands
      end      
      
      self.commands = SymbolHash[
        :builds => Builds,
        :users => Users
        ]
      
      def commands
        self.class.commands
      end
      
      # Convenience method to create a new CommandParser and call {#run}
      # @return (see #run)
      def self.run(*args) 
        new.run(*args) 
      end

      def initialize
        
      end

      # Runs the app
      # @return [void]
      def run (*args)
        # TODO: add help support
        if args.size == 0
          # TODO: print usage
        else
          cmd = args.first.to_sym
          args.shift        
          if cmd!=nil && commands.has_key?( cmd)
            handler = commands[cmd].new
            
            begin
              handler.run( *args)
            rescue UsageError => error
              puts "ERROR: #{error.inspect}"
            end
          else
            puts "wut u doin?"            
          end          
          
        end
      end
      
    end
    
  end
end

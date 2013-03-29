require 'app47/cli/symbol_hash.rb'
require 'app47/cli/builds.rb'
require 'app47/cli/users.rb'
require 'app47/cli/groups.rb'
require 'app47/cli/apps.rb'
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
        :users => Users,
        :groups => Groups,
        :apps => Apps
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
      
      def usage
        puts 'Usage: app47 <cmd> (-h | <options>)'
        puts 'Valid commands: '
        
        self.commands.each do |key,value|
          puts "\t#{key}"
        end
        
        puts ''
      end

      # Runs the app
      # @return [void]
      def run (*args)
        if args.size == 0
          usage
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
            usage
          end          
          
        end
      end
      
    end
    
  end
end

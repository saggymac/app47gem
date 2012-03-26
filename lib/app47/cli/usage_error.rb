
module App47
  module CLI
    
    class UsageError < Exception
      
      #
      # @param [String] msg the message describing the usage exception
      def initialize( msg )
        super        
      end
    end

  end
end
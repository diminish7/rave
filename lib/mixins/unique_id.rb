module Rave
  module Mixins
    module UniqueId
      
      #Seed for unique ids to make sure that they continue to be unique when the app restarts
      SEED = Time.now.to_f.to_s.gsub(".", "") unless defined?(SEED)
      
      def self.included(klazz)
        klazz.module_eval do
          #Define the id field
          attr_reader :id
          #init the next available id
          @@next_id = 0
          #Define the unique id generator
          define_method(:generate_id) do
            @id = "#{SEED}#{@@next_id}"
            @@next_id += 1
          end
        end
      end
      
    end
  end
end
#Contains the Rack #call method - to be mixed in to the Robot class
module Rave
  module Mixins
    module Controller
      
      def call(env)
        [200, {'Content-Type' => 'text/plain'}, "Hello world!" ]
      end
      
    end 
  end
end
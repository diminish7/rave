#Contains the Rack #call method - to be mixed in to the Robot class
module Rave
  module Mixins
    module Controller
      
      def call(env)
        request = Rack::Request.new(env)
        path = request.path_info
        method = request.request_method
        begin
          #There are only 3 URLs that Wave can access: 
          #  robot capabilities, robot profile, and event notification
          if path == "/_wave/capabilities.xml" && method == "GET"
            [ 200, { 'Content-Type' => 'text/xml' }, capabilities_xml ]
          elsif path == "/_wave/robot/profile" && method == "GET"
            [ 200, { 'Content-Type' => 'application/json' }, profile_json ]
          elsif path == "/_wave/robot/jsonrpc" && method == "POST"
            context, events = parse_json_body(request.body)
            events.each do |event|
              handle_event(event, context)
            end
            [ 200, { 'Content-Type' => 'application/json' }, context.to_json ]
          else
            #TODO: Log this
            [ 404, { 'Content-Type' => 'text/html' }, "404 - Not Found" ]
          end
        rescue Exception => e
          #TODO: Log this
          [ 500, { 'Content-Type' => 'text/html' }, "500 - Internal Server Error"]
        end
      end
      
    end 
  end
end
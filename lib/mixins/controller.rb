#Contains the Rack #call method - to be mixed in to the Robot class
module Rave
  module Mixins
    module Controller
      
      LOGGER = java.util.logging.Logger.getLogger("Controller")
      
      def call(env)
        request = Rack::Request.new(env)
        path = request.path_info
        method = request.request_method
        LOGGER.info("#{method}ing #{path}")
        begin
          #There are only 3 URLs that Wave can access: 
          #  robot capabilities, robot profile, and event notification
          if path == "/_wave/capabilities.xml" && method == "GET"
            [ 200, { 'Content-Type' => 'text/xml' }, capabilities_xml ]
          elsif path == "/_wave/robot/profile" && method == "GET"
            [ 200, { 'Content-Type' => 'application/json' }, profile_json ]
          elsif path == "/_wave/robot/jsonrpc" && method == "POST"
            body = request.body.read
            context, events = parse_json_body(body)
            events.each do |event|
              handle_event(event, context)
            end
            [ 200, { 'Content-Type' => 'application/json' }, context.to_json ]
          elsif cron_job = @cron_jobs.find { |job| job[:path] == path }
            # body = request.body.read
            # context, events = parse_json_body(body)
            self.send(cron_job[:handler], context)
            [ 200, { 'Content-Type' => 'application/json' }, context.to_json ]
          else
            #TODO: Also, give one more option: respond_to?(:non_robot_url) or something - can override in impl
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
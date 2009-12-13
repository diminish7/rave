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
            response = context.to_json
            LOGGER.info("Structure (after):\n#{context.print_structure}")
            LOGGER.info("Response:\n#{response}")
            [ 200, { 'Content-Type' => 'application/json' }, response ]
          elsif cron_job = @cron_jobs.find { |job| job[:path] == path }
            body = request.body.read
            context, events = parse_json_body(body)
            self.send(cron_job[:handler], context)
            [ 200, { 'Content-Type' => 'application/json' }, context.to_json ]
          elsif File.exist?(file = File.join(".", "public", *(path.split("/"))))
            #Static resource
            [ 200, { 'Content-Type' => static_resource_content_type(file) }, File.open(file) { |f| f.read } ]
          elsif self.respond_to?(:custom_routes)
            #Let the custom route method defined in the robot take care of the call
            self.custom_routes(request, path, method)
          else
            LOGGER.warning("404 - Not Found: #{path}")
            [ 404, { 'Content-Type' => 'text/html' }, "404 - Not Found" ]
          end
        rescue Exception => e
          LOGGER.warning("500 - Internal Server Error: #{path}")
          LOGGER.warning("#{e.class}: #{e.message}\n\n#{e.backtrace.join("\n")}")
          [ 500, { 'Content-Type' => 'text/html' }, "500 - Internal Server Error"]
        end
      end
      
    protected
      def static_resource_content_type(path)
        case (ext = File.extname(path))
        when '.html', '.htm'
          'text/html'
        when '.xml'
          'text/xml'
        when '.gif'
          'image/gif'
        when '.jpeg', '.jpg'
          'image/jpeg'
        when '.tif', '.tiff'
          'image/tiff'
        when '.txt', ''
          'text/plain'
        else
          "application/#{ext}"
        end
      end
    end 
  end
end

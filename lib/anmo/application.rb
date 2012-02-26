require "ostruct"

module Anmo
  class Application
    def call env
      @stored_requests ||= []
      request = Rack::Request.new(env)

      if request.path_info == "/__CREATE__"
        process_create_request request
      elsif request.path_info == "/__DELETE_ALL__"
        process_delete_all_request request
      else
        process_normal_request request
      end
    end

    private

      def process_create_request request
        request_info = JSON.parse(read_request_body(request))
        @stored_requests.unshift(request_info)
        [201, {}, ""]
      end

      def process_delete_all_request request
        @stored_requests = []
        [200, {}, ""]
      end

      def process_normal_request request
        if found_request = find_stored_request(request)
          [Integer(found_request["status"]||200), {"Content-Type" => "text/html"}, [found_request["body"]]]
        else
          [404, {"Content-Type" => "text/html"}, "Not Found"]
        end
      end

      def find_stored_request actual_request
        found_request = @stored_requests.find {|r| r["path"] == actual_request.path_info}
        if found_request
          required_headers = found_request["required_headers"] || []
          required_headers.each do |name, value|
            if actual_request.env[convert_header_name_to_rack_style_name(name)] != value
              found_request = nil
              break
            end
          end
        end
        found_request
      end

      def convert_header_name_to_rack_style_name name
        name = "HTTP_#{name}"
        name.gsub!("-", "_")
        name.upcase!
        name
      end

      def read_request_body request
        request.body.rewind
        request.body.read
      end
  end
end

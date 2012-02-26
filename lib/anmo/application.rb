require "ostruct"

module Anmo
  class Application
    def call env
      @stored_requests ||= []
      request = Rack::Request.new(env)

      if request.path_info == "/__CREATE__"
        @stored_requests << request
      elsif request.path_info == "/__DELETE_ALL__"
        @stored_requests = []
      end

      if found_request = find_stored_request(request)
        values = extract_anmo_values(found_request)
        [values.status, {"Content-Type" => "text/html"}, values.body]
      else
        [404, {"Content-Type" => "text/html"}, "Not Found"]
      end
    end

    private

      def find_stored_request actual_request
        found_request = @stored_requests.find {|r| r.env["HTTP_ANMO_PATH"] == actual_request.path_info}
        if found_request
          required_headers = found_request.env["HTTP_ANMO_REQUIRED_HEADERS"] || []
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

      def extract_anmo_values request
        values = OpenStruct.new
        values.body = request.env["HTTP_ANMO_BODY"] || ""
        values.status = Integer(request.env["HTTP_ANMO_HTTP_STATUS"] || 200)
        values
      end

      def read_request_body request
        request.body.rewind
        request.body.read
      end
  end
end

module Anmo
  class Application
    def call env
      @stored_objects ||= []
      @@stored_requests ||= []

      request = Rack::Request.new(env)

      if request.path_info == "/__CREATE__"
        create request
      elsif request.path_info == "/__DELETE_ALL__"
        process_delete_all_request request
      elsif request.path_info == "/__REQUESTS__"
        requests request
      elsif request.path_info == "/__DELETE_ALL_REQUESTS__"
        delete
      elsif request.path_info == "/__STORED_OBJECTS__"
        process_stored_objects_request
      else
        @@stored_requests << request.env
        process_normal_request request
      end
    end

    def self.delete_all_requests
      @@stored_requests = []
    end

    private

      def create request
        request_info = JSON.parse(read_request_body(request))
        @stored_objects.unshift(request_info)
        [201, {}, ""]
      end

      def process_delete_all_request request
        @stored_objects = []
        [200, {}, ""]
      end

      def process_normal_request request
        if found_request = find_stored_request(request)
          [Integer(found_request["status"]||200), {"Content-Type" => "text/html"}, [found_request["body"]]]
        else
          [404, {"Content-Type" => "text/html"}, "Not Found"]
        end
      end

      def requests request
        [200, {"Content-Type" => "application/json"}, (@@stored_requests || []).to_json]
      end

      def delete
        Application.delete_all_requests
        [200, {}, ""]
      end

      def process_stored_objects_request
        [200, {"Content-Type" => "application/json"}, [@stored_objects.to_json]]
      end

      def find_stored_request actual_request
        actual_request_url = actual_request.path_info
        if actual_request.query_string != ""
          actual_request_url << "?" + actual_request.query_string
        end

        found_request = @stored_objects.find {|r| r["path"] == actual_request_url}
        if found_request
          if found_request["method"]
            if actual_request.request_method != found_request["method"].upcase
              return
            end
          end

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

module Anmo
  class ApplicationDataStore
    class << self
      attr_accessor :stored_objects, :stored_requests
    end
  end

  class Application
    def initialize
      ApplicationDataStore.stored_objects ||= []
      ApplicationDataStore.stored_requests ||= []
    end

    def call env
      request = Rack::Request.new(env)

      controller_methods = [
        :alive,
        :create_object,
        :delete_all_objects,
        :requests,
        :delete_all_requests,
        :objects
      ]

      method = controller_methods.find {|m| request.path_info =~ /\/?__#{m.upcase}__\/?/}
      method ||= :process_normal_request
      send(method, request)
    end

    private

      def alive request
        [200, {"Content-Type" => "text/html"}, ["<h1>anmo is alive</h1>"]]
      end

      def create_object request
        request_info = JSON.parse(read_request_body(request))
        ApplicationDataStore.stored_objects.unshift(request_info)
        [201, {"Content-Type" => "text/html"}, [""]]
      end

      def delete_all_objects request
        ApplicationDataStore.stored_objects = []
        [200, {"Content-Type" => "text/html"}, [""]]
      end

      def process_normal_request request
        ApplicationDataStore.stored_requests << request.env

        if found_request = find_stored_request(request)
          [Integer(found_request["status"]||200), {"Content-Type" => "text/html"}, [found_request["body"]]]
        else
          [404, {"Content-Type" => "text/html"}, ["Not Found"]]
        end
      end

      def requests request
        [200, {"Content-Type" => "application/json"}, [(ApplicationDataStore.stored_requests || []).to_json]]
      end

      def delete_all_requests request
        ApplicationDataStore.stored_requests = []
        [200, {"Content-Type" => "text/html"}, ""]
      end

      def objects request
        [200, {"Content-Type" => "application/json"}, [ApplicationDataStore.stored_objects.to_json]]
      end

      def find_stored_request actual_request
        actual_request_url = actual_request.path_info
        if actual_request.query_string != ""
          actual_request_url << "?" + actual_request.query_string
        end

        found_request = ApplicationDataStore.stored_objects.find {|r| r["path"] == actual_request_url}
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

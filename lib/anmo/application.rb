require "dalli"

module Anmo
  class ApplicationDataStore
    TTL = 1000000
    def self.objects
      cached_objects = server.get("objects")
      return JSON.load(cached_objects) if cached_objects
      []
    end

    def self.requests
      cached_requests = server.get("requests")
      return JSON.load(cached_requests) if cached_requests
      []
    end

    def self.insert_object object
      all_objects = objects
      all_objects.unshift(object)
      server.set("objects", JSON.dump(all_objects), TTL)
    end

    def self.save_request request
      all_requests = requests
      all_requests << request
      server.set("requests", JSON.dump(all_requests), TTL)
    end

    def self.clear_objects
      server.delete("objects")
    end

    def self.clear_requests
      server.delete("requests")
    end

    private
      def self.server
        @server ||= Dalli::Client.new "localhost:11211", {:namespace => Process.pid.to_s}
      end
  end

  class Application
    def initialize
      ApplicationDataStore.clear_objects
      ApplicationDataStore.clear_requests
    end

    def call env
      request = Rack::Request.new(env)

      controller_methods = [
        :alive,
        :version,
        :create_object,
        :objects,
        :requests,
        :delete_all_objects,
        :delete_all_requests
      ]

      method = controller_methods.find {|m| request.path_info =~ /\/?__#{m.to_s.upcase}__\/?/}
      method ||= :process_normal_request
      send(method, request)
    end

    private

      def text text, status = 200
        [status, {"Content-Type" => "text/html"}, [text]]
      end

      def json json, status = 200
        [status, {"Content-Type" => "application/json"}, [json]]
      end

      def alive request
        text "<h1>anmo is alive</h1>"
      end

      def version request
        text Anmo::VERSION
      end

      def create_object request
        request_info = JSON.parse(read_request_body(request))
        ApplicationDataStore.insert_object(request_info)
        text "", 201
      end

      def delete_all_objects request
        ApplicationDataStore.clear_objects
        text ""
      end

      def process_normal_request request
        ApplicationDataStore.save_request(request.env)

        if found_request = find_stored_request(request)
          text found_request["body"], Integer(found_request["status"]||200)
        else
          text "Not Found", 404
        end
      end

      def requests request
        json ApplicationDataStore.requests.to_json
      end

      def delete_all_requests request
        ApplicationDataStore.clear_requests
        text ""
      end

      def objects request
        json ApplicationDataStore.objects.to_json
      end

      def find_stored_request actual_request
        actual_request_query = Rack::Utils.parse_query(actual_request.query_string)

        suspected_request = ApplicationDataStore.objects.find do |r|
          r["path"].gsub(/\?.*/, "") == actual_request.path_info
        end

        if suspected_request
          return unless request_has_same_method actual_request, suspected_request
          return unless request_has_same_query actual_request, suspected_request
          return unless request_has_required_headers actual_request, suspected_request
        end
        suspected_request
      end

      def request_has_same_method initial_request, suspected_request
        return true if suspected_request["method"] == nil
        suspected_request["method"].upcase == initial_request.request_method
      end

      def request_has_same_query initial_request, suspected_request
        return true if suspected_request["path"].include?("?") == false
        query = Rack::Utils.parse_query(suspected_request["path"].gsub(/.*\?/, ""))
        query == Rack::Utils.parse_query(initial_request.query_string)
      end

      def request_has_required_headers initial_request, suspected_request
        required_headers = suspected_request["required_headers"] || []
        required_headers.each do |name, value|
          if initial_request.env[convert_header_name_to_rack_style_name(name)] != value
            return false
          end
        end
        true
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

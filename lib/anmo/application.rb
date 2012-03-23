module Anmo
  class ApplicationDataStore
    class << self
      [:requests, :objects].each do |t|
        define_method :"reset_#{t}!" do
          instance_variable_set(:"@stored_#{t}", {})
        end

        define_method :"stored_#{t}" do |host|
          name = :"@stored_#{t}"
          instance_variable_set(name, {}) unless instance_variable_get(name)
          values = instance_variable_get(name)
          values[host] ||= []
          values[host]
        end
      end
    end
  end

  class Application
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

      def stored_requests request
        ApplicationDataStore.stored_requests(request.host)
      end

      def stored_objects request
        ApplicationDataStore.stored_objects(request.host)
      end

      def alive request
        text "<h1>anmo is alive</h1>"
      end

      def version request
        text Anmo::VERSION
      end

      def create_object request
        request_info = JSON.parse(read_request_body(request))
        stored_objects(request).unshift(request_info)
        text "", 201
      end

      def delete_all_objects request
        ApplicationDataStore.reset_objects!
        text ""
      end

      def process_normal_request request
        stored_requests(request) << request.env

        if found_request = find_stored_request(request)
          text found_request["body"], Integer(found_request["status"]||200)
        else
          text "Not Found", 404
        end
      end

      def requests request
        json stored_requests(request).to_json
      end

      def delete_all_requests request
        ApplicationDataStore.reset_requests!
        text ""
      end

      def objects request
        json stored_objects(request).to_json
      end

      def find_stored_request actual_request
        actual_request_url = actual_request.path_info
        if actual_request.query_string != ""
          actual_request_url << "?" + actual_request.query_string
        end

        found_request = stored_objects(actual_request).find {|r| r["path"] == actual_request_url}
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

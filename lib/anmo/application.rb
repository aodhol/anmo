require "ostruct"

module Anmo
  class Application
    def call env
      @stored_requests ||= []
      request = Rack::Request.new(env)

      if request.path_info == "/__CREATE__"
        @stored_requests << request
      end

      found_request = @stored_requests.find {|r| r.env["HTTP_ANMO_PATH"] == request.path_info}
      if found_request
        values = extract_anmo_values(found_request)
        [values.status, {"Content-Type" => "text/html"}, values.body]
      else
        [404, {"Content-Type" => "text/html"}, "Not Found"]
      end
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

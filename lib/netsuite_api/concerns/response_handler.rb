module NetsuiteApi
  module Concerns
    module ResponseHandler
      class NetSuiteApiError < StandardError
        attr_reader :title, :details
        def initialize(title, details)
          @title = title
          @details = details
          msg = "#{title}: #{details}"
          super(msg)
        end
      end

      def get_response_handler(response)
        if response.success?
          JSON.parse(response.body)
        else
          error_handler(response)
        end
      end
    
      def post_and_patch_response_handler(response)
        if response.success?
          location = response.headers["location"]
          if location
            location.split('/').last
          else
            NetsuiteApi.logger.error("NetSuite API Error: No location header in response")
            nil
          end
        else
          error_handler(response)
        end
      end
    
      def delete_response_handler(response)
        if response.success?
          true
        else
          error_handler(response)
        end
      end

      def error_handler(response)
        begin
          response_body = JSON.parse(response.body)
          title = response_body["title"] || "NetSuite API Error"
          details = response_body["o:errorDetails"] || "No additional details provided."
        rescue JSON::ParserError
          title = "Invalid API Response"
          details = response.body.to_s.strip.empty? ? "Empty response body" : response.body
        end

        NetsuiteApi.logger.error("NetSuite API Error: #{title} - #{details}")
        raise NetSuiteApiError.new(title, details)
      end
    end
  end
end

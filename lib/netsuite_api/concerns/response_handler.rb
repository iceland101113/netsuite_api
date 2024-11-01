module NetsuiteApi
  module Concerns
    module ResponseHandler
      class NetSuiteApiError < StandardError
        attr_reader :title, :details
        def initialize(msg, title, details)
          @title = title
          @details = details
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
          response.headers["location"].split('/').last
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
        response_body = JSON.parse(response.body)
        raise NetSuiteApiError.new(response_body["title"], response_body["title"], response_body["o:errorDetails"])
      end
    end
  end
end

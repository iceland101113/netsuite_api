module NetsuiteApi
  module Concerns
    module RequestHandler

      def get(id, query_params: nil)
        response = request("#{self.class::PATH}/#{id}", query_params: query_params, host_type: :netsuite_host)
        get_response_handler(response)
      end
  
      def create(body)
        response = request("#{self.class::PATH}", body: body, method: :post, host_type: :netsuite_host)
        post_and_patch_response_handler(response)
      end
  
      def update(id, body, query_params: nil)
        response = request("#{self.class::PATH}/#{id}", body: body, method: :patch, host_type: :netsuite_host)
        post_and_patch_response_handler(response)
      end
  
      def delete(id)
        response = request("#{self.class::PATH}/#{id}", method: :delete, host_type: :netsuite_host)
        delete_response_handler(response)
      end

      def query(query)
        response = request("#{self.class::PATH}", query_params: query, host_type: :netsuite_host)
        get_response_handler(response)
      end
    end
  end
end

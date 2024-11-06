require 'netsuite_api/base'
require 'netsuite_api/concerns/request_handler'
require 'netsuite_api/concerns/response_handler'

module NetsuiteApi
  class Invoice < Base
    include Concerns::RequestHandler
    include Concerns::ResponseHandler

    PATH = "invoice"

    def get_pdf(query)
      path = "app/site/hosting/restlet.nl"
      response = request(path, query_params: query, host_type: :netsuite_pdf_host)
      
      if response.success?
        ecrypted_str = JSON.parse(response.body).dig('data64')
        plain = Base64.decode64(ecrypted_str)
      else
        nil
      end
    end
  end
end

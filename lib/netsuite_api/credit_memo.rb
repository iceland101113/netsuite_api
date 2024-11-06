require 'netsuite_api/base'
require 'netsuite_api/concerns/request_handler'
require 'netsuite_api/concerns/response_handler'

module NetsuiteApi
  class CreditMemo < Base
    include Concerns::RequestHandler
    include Concerns::ResponseHandler

    PATH = "creditMemo"

    def create(invoice_id, params)
      response = request("invoice/#{invoice_id}/!transform/#{PATH}", body: params, method: :post, host_type: :netsuite_host)
      post_and_patch_response_handler(response)
    end
  end
end

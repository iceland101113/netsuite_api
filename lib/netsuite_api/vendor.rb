require 'netsuite_api/base'
require 'netsuite_api/concerns/request_handler'
require 'netsuite_api/concerns/response_handler'

module NetsuiteApi
  class Vendor < Base
    include Concerns::RequestHandler
    include Concerns::ResponseHandler

    PATH = "vendor"
  end
end

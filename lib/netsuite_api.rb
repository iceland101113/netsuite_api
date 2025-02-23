require "netsuite_api/version"
require "netsuite_api/invoice"
require "netsuite_api/credit_memo"
require "netsuite_api/customer"
require "netsuite_api/contact"
require "netsuite_api/payment"
require "netsuite_api/vendor"
require "netsuite_api/vendor_bill"
require "logger"

module NetsuiteApi
  class << self
    attr_accessor :logger
  end

  # 預設 Logger 為 STDOUT
  self.logger = Logger.new(STDOUT)
end

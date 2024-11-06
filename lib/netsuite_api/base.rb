require 'faraday'
require 'securerandom'
require 'active_support/core_ext/object'

module NetsuiteApi
  class Base
    attr_reader :netsuite_host, :account_id, :consumer_key, :token

    def initialize(netsuite_host: nil, netsuite_pdf_host: nil, account_id: nil, consumer_key: nil, token: nil, token_secret: nil, consumer_secret: nil)
      @netsuite_host = netsuite_host || ENV['NETSUITE_HOST']
      @netsuite_pdf_host = netsuite_pdf_host || ENV['NETSUITE_PDF_HOST']
      @account_id = account_id || ENV['NETSUITE_ACCOUNT_ID']
      @consumer_key = consumer_key || ENV['NETSUITE_CONSUMER_KEY']
      @token = token || ENV['NETSUITE_TOKEN_ID']
      @token_secret = token_secret || ENV['NETSUITE_TOKEN']
      @consumer_secret = consumer_secret || ENV['NETSUITE_CONSUMER_SECRET']
    end

    def request(url, query_params: nil, host_type: :netsuite_host, body: nil, method: :get, headers: {})
      host = host_options[host_type]
      connection(host).send(method) do |req|
        req.url full_url(url, query_params)
        req.headers["Authorization"] = authorization_header(url, method, query_params, host: host)
        req.headers["Content-Type"] = "application/json"
        req.headers.merge!(headers)
        req.body = JSON.dump(body) if body
      end
    end

    private

    def connection(host)
      conn = Faraday.new(url: host) do |faraday|
        faraday.adapter Faraday.default_adapter
        faraday.ssl.verify = true # You can set this to false if you have SSL verification issues
      end
    end

    def host_options
      { netsuite_host: @netsuite_host, netsuite_pdf_host: @netsuite_pdf_host }
    end

    def authorization_header(url, method, query_params, host:)
      "OAuth realm=\"#{account_id}\",oauth_consumer_key=\"#{consumer_key}\",oauth_token=\"#{token}\",oauth_signature_method=\"HMAC-SHA256\",oauth_timestamp=\"#{oauth_timestamp}\",oauth_nonce=\"#{oauth_nonce}\",oauth_version=\"1.0\",oauth_signature=\"#{generate_oauth_signature(url, method, query_params, host: host)}\""
    end

    def oauth_nonce
      @oauth_nonce = SecureRandom.hex(16)
    end
  
    def oauth_timestamp
      @oauth_timestamp = Time.now.to_i
    end
  
    def full_url(url, query_params)
      if query_params
        "#{url}?#{query_params.to_query}"
      else
        url
      end
    end
  
    def url_encode(url)
      CGI.escape(url)
    end
  
    def generate_oauth_signature(url, http_method, query_params, host:)
      # Step 1: Combine parameters
      all_params = {
        'oauth_consumer_key' => consumer_key,
        'oauth_token' => token,
        'oauth_signature_method' => 'HMAC-SHA256',
        'oauth_timestamp' => @oauth_timestamp,
        'oauth_nonce' => @oauth_nonce, # Generate a random nonce
        'oauth_version' => '1.0'
      }
      all_params.merge!(query_params) if query_params
  
      # Step 2: Normalize parameters
      normalized_params = all_params.sort.map { |k, v| url_encode("#{k}=#{URI.encode_www_form_component(v).gsub('+', '%20')}") }.join('%26') 
  
      # Step 3: Generate Signature Base String (SBS)
      sbs = "#{http_method.to_s.upcase}&#{url_encode("#{host}#{url}")}&#{normalized_params}"
    
      # Step 4: Generate Signing Key
      signing_key = "#{@consumer_secret}&#{@token_secret}"
      
      # Step 5: Sign the Signature Base String
      digest = OpenSSL::Digest.new('sha256')
      hmac = OpenSSL::HMAC.digest(digest, signing_key, sbs)
      
      oauth_signature = CGI.escape(Base64.encode64(hmac).chomp.gsub('\n', ''))
    
      oauth_signature
    end
  end
end

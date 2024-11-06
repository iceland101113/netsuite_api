RSpec.describe NetsuiteApi::Customer do
  before do 
    stub_request(:get, 'https://netsuite-test.domain/customer/1')
      .to_return(status: 200, body:  { "id": "1", "companyName" => "Test School 20241104 01", "subsidiary" => { "id" => "8" }, "addressBook" => { "items" => [{ "addressBookAddress" => { "addr1" => "test street", "city" => "test city" }}]}, "email" => "test@example.com", "phone" => "1234567890", "currency": { "id": "2", "refName": "USD" }}.to_json, headers: {})
    stub_request(:post, 'https://netsuite-test.domain/customer')
      .to_return(status: 200, body: "", headers: { "location" => "domain/2"})
    stub_request(:patch, 'https://netsuite-test.domain/customer/1')
      .to_return(status: 200, body: "", headers: { "location" => "domain/1"})
    stub_request(:delete, 'https://netsuite-test.domain/customer/1')
      .to_return(status: 200, body: "", headers: {})
    stub_request(:get, 'https://netsuite-test.domain/customer?q=externalId%20ANY_OF%20%5BT123%5D')
      .to_return(status: 200, body: { "count": 1, "hasMore": false, "items": [{"id": "1"}], "offset": 0, "totalResults": 1 }.to_json, headers: {})
  end

  it '#get' do
    customer = NetsuiteApi::Customer.new(netsuite_host: 'https://netsuite-test.domain/').get(1)
    expect(customer.dig("id")).to eq("1")
  end

  it '#create' do
    params = { "companyName" => "Test School 20241104 02", "subsidiary" => { "id" => "8" }, "addressBook" => { "items" => [{ "addressBookAddress" => { "addr1" => "test street", "city" => "test city" }}]}, "email" => "test@example.com", "phone" => "1234567890", "currency": { "id": "2" }}
    customer_id = NetsuiteApi::Customer.new(netsuite_host: 'https://netsuite-test.domain/').create(params)
    expect(customer_id).to eq("2")
  end

  it '#update' do
    customer_id = NetsuiteApi::Customer.new(netsuite_host: 'https://netsuite-test.domain/').update(1, { "externalId": "T123" })
    expect(customer_id).to eq("1")
  end

  it '#delete' do
    result = NetsuiteApi::Customer.new(netsuite_host: 'https://netsuite-test.domain/').delete(1)
    expect(result).to eq(true)
  end

  it '#query' do
    result = NetsuiteApi::Customer.new(netsuite_host: 'https://netsuite-test.domain/').query({ "q" => "externalId ANY_OF [T123]" })
    expect(result.dig("count")).to eq(1)
  end
end

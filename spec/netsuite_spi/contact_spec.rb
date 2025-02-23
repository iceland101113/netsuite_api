RSpec.describe NetsuiteApi::Contact do 
  before do 
    stub_request(:get, "https://netsuite-test.domain/contact/1")
      .to_return(status: 200, body: { "id": "1", "company" => { "id" => "12" }, "subsidiary" => { "id" => "8" }, "firstName" => "Test", "lastName" => "Example", "email" => "test.example@example.com"}.to_json, headers: {})
    stub_request(:post, "https://netsuite-test.domain/contact")
      .to_return(status: 200, body: "", headers: { "location" => "domain/2"})
    stub_request(:patch, "https://netsuite-test.domain/contact/1")
      .to_return(status: 200, body: "", headers: { "location" => "domain/1"})
    stub_request(:delete, "https://netsuite-test.domain/contact/1")
      .to_return(status: 200, body: "", headers: {})
    stub_request(:get, "https://netsuite-test.domain/contact?q=lastName%20CONTAIN%20Example")
      .to_return(status: 200, body: { "count": 1, "hasMore": false, "items": [{"id": "1"}], "offset": 0, "totalResults": 1 }.to_json, headers: {})
  end

  it "#get" do
    contact = NetsuiteApi::Contact.new(netsuite_host: "https://netsuite-test.domain/").get(1)
    expect(contact.dig("id")).to eq("1")
  end

  it "#create" do
    params = { "company" => { "id" => "12" }, "firstName" => "Test2", "lastName" => "Example", "email" => "test2.example@example.com"}
    contact_id = NetsuiteApi::Contact.new(netsuite_host: "https://netsuite-test.domain/").create(params)
    expect(contact_id).to eq("2")
  end

  it "#update" do
    contact_id = NetsuiteApi::Contact.new(netsuite_host: "https://netsuite-test.domain/").update(1, { "email" => "test2@example.com" })
    expect(contact_id).to eq("1")
  end

  it "#delete" do
    result = NetsuiteApi::Contact.new(netsuite_host: "https://netsuite-test.domain/").delete(1)
    expect(result).to eq(true)
  end

  it "#query" do
    result = NetsuiteApi::Contact.new(netsuite_host: "https://netsuite-test.domain/").query({ "q" => "lastName CONTAIN Example" })
    expect(result.dig("count")).to eq(1)
  end

  it 'response error' do
    stub_request(:get, 'https://netsuite-test.domain/contact/1')
      .to_return(status: 401, body: { "title": "Unauthorized", "o:errorDetails": "Invalid login attempt" }.to_json, headers: {})
    expect { NetsuiteApi::Contact.new(netsuite_host: 'https://netsuite-test.domain/').get(1) }.to raise_error(NetsuiteApi::Concerns::ResponseHandler::NetSuiteApiError)
  end

  it 'response empty body' do
    stub_request(:get, 'https://netsuite-test.domain/contact/1')
      .to_return(status: 400, body: {}.to_json, headers: {})
    expect { NetsuiteApi::Contact.new(netsuite_host: 'https://netsuite-test.domain/').get(1) }.to raise_error(NetsuiteApi::Concerns::ResponseHandler::NetSuiteApiError)
  end

  it '#create no location in response header' do
    stub_request(:post, 'https://netsuite-test.domain/contact')
      .to_return(status: 200, body: "", headers: {})
    
    expect(NetsuiteApi.logger).to receive(:error).with("NetSuite API Error: No location header in response")
    params = { "company" => { "id" => "12" }, "firstName" => "Test2", "lastName" => "Example", "email" => "test2.example@example.com"}
    contact_id = NetsuiteApi::Contact.new(netsuite_host: "https://netsuite-test.domain/").create(params)
    expect(contact_id).to eq(nil)
  end
end

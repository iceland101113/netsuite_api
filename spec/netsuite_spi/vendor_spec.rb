RSpec.describe NetsuiteApi::Vendor do
  before do
    stub_request(:get, "https://netsuite-test.domain/vendor/1")
      .to_return(status: 200, body: { "id": "1", "companyName" => "Test Example", "subsidiary" => { "id" => "8" }, "addressBook" => { "items" => [{ "addressBookAddress" => { "addr1" => "test street", "city" => "test city" }}]}, "currency": { "id": "2", "refName": "USD" }}.to_json, headers: {})
    stub_request(:post, "https://netsuite-test.domain/vendor")
      .to_return(status: 200, body: "", headers: { "location" => "domain/2"})
    stub_request(:patch, "https://netsuite-test.domain/vendor/1")
      .to_return(status: 200, body: "", headers: { "location" => "domain/1"})
    stub_request(:delete, "https://netsuite-test.domain/vendor/1")
      .to_return(status: 200, body: "", headers: {})
    stub_request(:get, "https://netsuite-test.domain/vendor?q=companyName%20CONTAIN%20Example")
      .to_return(status: 200, body: { "count": 1, "hasMore": false, "items": [{"id": "1"}], "offset": 0, "totalResults": 1 }.to_json, headers: {})
  end

  it "#get" do
    vendor = NetsuiteApi::Vendor.new(netsuite_host: "https://netsuite-test.domain/").get(1)
    expect(vendor.dig("id")).to eq("1")
  end

  it "#create" do
    params = { "companyName" => "Test2 Example", "subsidiary" => { "id" => "8" }, "addressBook" => { "items" => [{ "addressBookAddress" => { "addr1" => "test street", "city" => "test city" }}]}, "currency": { "id": "2" }}
    vendor_id = NetsuiteApi::Vendor.new(netsuite_host: "https://netsuite-test.domain/").create(params)
    expect(vendor_id).to eq("2")
  end

  it "#update" do
    vendor_id = NetsuiteApi::Vendor.new(netsuite_host: "https://netsuite-test.domain/").update(1, { "externalId" => "Test-01" })
    expect(vendor_id).to eq("1")
  end

  it "#delete" do
    result = NetsuiteApi::Vendor.new(netsuite_host: "https://netsuite-test.domain/").delete(1)
    expect(result).to eq(true)
  end

  it "#query" do
    result = NetsuiteApi::Vendor.new(netsuite_host: "https://netsuite-test.domain/").query({ "q" => "companyName CONTAIN Example" })
    expect(result.dig("count")).to eq(1)
  end    
end

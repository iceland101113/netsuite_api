RSpec.describe NetsuiteApi::VendorBill do
  before do 
    body = {
              "id" => "1",
              "entity" => {
                  "id" => "742"
              },
              "item" => {
                  "items" => [
                      {
                          "amount" => 1000.0,
                          "item" => {
                              "id" => "26"
                          }
                      }
                  ]
              },
              "subsidiary" => {
                  "id" => "8"
              },
              "currency" => {
                  "id": "2"
              },
              "total" => 1000.0,
              "tranDate" => "2024-11-04",
              "approvalStatus": {
                "id": "2",
                "refName": "Approved"
              },
              "status": {
                "id": "Paid In Full",
                "refName": "Paid In Full"
              }
            } 
    stub_request(:get, "https://netsuite-test.domain/vendorBill/1")
      .to_return(status: 200, body: body.to_json, headers: {})
    stub_request(:post, "https://netsuite-test.domain/vendorBill")
      .to_return(status: 200, body: "", headers: { "location" => "domain/2"})
    stub_request(:patch, "https://netsuite-test.domain/vendorBill/1")
      .to_return(status: 200, body: "", headers: { "location" => "domain/1"})
    stub_request(:delete, "https://netsuite-test.domain/vendorBill/1")
      .to_return(status: 200, body: "", headers: {})
    stub_request(:get, "https://netsuite-test.domain/vendorBill?q=entity%20EQUAL%202")
      .to_return(status: 200, body: { "count": 1, "hasMore": false, "items": [{"id": "1"}], "offset": 0, "totalResults": 1 }.to_json, headers: {})
  end

  it "#get" do
    vendor_bill = NetsuiteApi::VendorBill.new(netsuite_host: "https://netsuite-test.domain/").get(1)
    expect(vendor_bill.dig("id")).to eq("1")
  end

  it "#create" do
    params = {
                "entity" => {
                    "id" => "742"
                },
                "item" => {
                    "items" => [
                        {
                            "amount" => 1000.0,
                            "item" => {
                                "id" => "26"
                            }
                        }
                    ]
                },
                "subsidiary" => {
                    "id" => "8"
                },
                "currency" => {
                    "id": "2"
                },
                "total" => 1000.0,
              } 
    vendor_bill_id = NetsuiteApi::VendorBill.new(netsuite_host: "https://netsuite-test.domain/").create(params)
    expect(vendor_bill_id).to eq("2")
  end

  it "#update" do
    vendor_bill_id = NetsuiteApi::VendorBill.new(netsuite_host: "https://netsuite-test.domain/").update(1, { "externalId": "T123" })
    expect(vendor_bill_id).to eq("1")
  end

  it "#delete" do
    result = NetsuiteApi::VendorBill.new(netsuite_host: "https://netsuite-test.domain/").delete(1)
    expect(result).to eq(true)
  end

  it "#query" do
    result = NetsuiteApi::VendorBill.new(netsuite_host: "https://netsuite-test.domain/").query({ "q" => "entity EQUAL 2" })
    expect(result.dig("count")).to eq(1)
  end
end

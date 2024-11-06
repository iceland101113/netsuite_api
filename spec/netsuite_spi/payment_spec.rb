RSpec.describe NetsuiteApi::Payment do
  before do
    body = {
              "id": "1",
              "applied": 10,
              "apply": {
                  "items": [
                      {
                          "amount": 10,
                          "applyDate": "2024-11-04",
                          "currency": "USD",
                          "doc": {
                              "id": "103912",
                              "refName": "103912"
                          },
                          "due": 10,
                          "total": 10,
                          "type": "Invoice"
                      }
                  ]
              },
              "currency": {
                  "id": "2"
              },
              "customer": {
                  "id": "27480"
              },
              "subsidiary": {
                  "id": "9"
              },
              "status": {
                "id": "Deposited",
                "refName": "Deposited"
              },
              "total": 10,
              "tranDate": "2024-11-04",
              "tranId": "PA-MBL-1"
            }

    stub_request(:get, "https://netsuite-test.domain/customerpayment/1")
      .to_return(status: 200, body: body.to_json, headers: {})
    stub_request(:post, "https://netsuite-test.domain/customerpayment")
      .to_return(status: 200, body: "", headers: { "location" => "domain/2"})
    stub_request(:patch, "https://netsuite-test.domain/customerpayment/1")
      .to_return(status: 200, body: "", headers: { "location" => "domain/1"})
    stub_request(:delete, "https://netsuite-test.domain/customerpayment/1")
      .to_return(status: 200, body: "", headers: {})
    stub_request(:get, "https://netsuite-test.domain/customerpayment?q=currency%20EQUAL%202")
      .to_return(status: 200, body: { "count": 1, "hasMore": false, "items": [{"id": "1"}], "offset": 0, "totalResults": 1 }.to_json, headers: {})
    stub_request(:get, "https://netsuite-test-pdf.domain/app/site/hosting/restlet.nl?deploy=1&pdfScriptId=CUSTTMPL_SW_MBLLC_USD_PAYMENT&recordId=1&recordTypeId=customerpayment&script=647")
      .to_return(status: 200, body: { "data64": "cGRm" }.to_json, headers: {})
  end

  it "#get" do
    payment = NetsuiteApi::Payment.new(netsuite_host: "https://netsuite-test.domain/").get(1)
    expect(payment.dig("tranId")).to eq("PA-MBL-1")
  end

  it "#create" do
    params = {
                "applied": 10,
                "apply": {
                    "items": [
                        {
                            "amount": 10,
                            "applyDate": "2024-11-04",
                            "currency": "USD",
                            "doc": {
                                "id": "103912",
                                "refName": "103912"
                            },
                            "due": 10,
                            "total": 10,
                            "type": "Invoice"
                        }
                    ]
                },
                "currency": {
                    "id": "2"
                },
                "customer": {
                    "id": "27480"
                },
                "subsidiary": {
                    "id": "9"
                },
                "total": 10,
                "tranDate": "2024-11-04"
              }
    
    payment_id = NetsuiteApi::Payment.new(netsuite_host: "https://netsuite-test.domain/").create(params)
    expect(payment_id).to eq("2")
  end

  it "#update" do
    payment_id = NetsuiteApi::Payment.new(netsuite_host: "https://netsuite-test.domain/").update(1, { "tranDate" => "2024-09-02" })
    expect(payment_id).to eq("1")
  end

  it "#delete" do
    result = NetsuiteApi::Payment.new(netsuite_host: "https://netsuite-test.domain/").delete(1)
    expect(result).to eq(true)
  end

  it "#query" do
    result = NetsuiteApi::Payment.new(netsuite_host: "https://netsuite-test.domain/").query({ "q" => "currency EQUAL 2" })
    expect(result.dig("count")).to eq(1)
  end

  it "#get_pdf" do
    query = {
        "script" => 647,
        "deploy" => 1,
        "recordTypeId" => "customerpayment",
        "recordId" => 1,
        "pdfScriptId" => "CUSTTMPL_SW_MBLLC_USD_PAYMENT"
      }
    pdf = NetsuiteApi::Payment.new(netsuite_pdf_host: 'https://netsuite-test-pdf.domain/').get_pdf(query)
    expect(pdf).to eq("pdf")
  end
end


# {
#   "applied": 577.5,
#   "apply": {
#       "items": [
#           {
#               "amount": 577.5,
#               "apply": true,
#               "applyDate": "2024-06-26",
#               "currency": "USD",
#               "doc": {
#                   "id": "112331",
#                   "refName": "112331"
#               },
#               "due": 577.5,
#               "line": 0,
#               "refNum": "MBL-240161",
#               "total": 577.5,
#               "type": "Invoice"
#           },
#       ],
#       "totalResults": 1
#   },
#   "createdDate": "2024-06-27T03:38:00Z",
#   "currency": {
#       "id": "2",
#       "refName": "USD"
#   },
#   "customer": {
#       "id": "75999",
#       "refName": "25635 Norway June 2024 School"
#   },
#   "id": "112429",
#   "payment": 577.5,
#   "status": {
#       "id": "Deposited",
#       "refName": "Deposited"
#   },
#   "subsidiary": {
#       "id": "5",
#       "refName": "MBLLC"
#   },
#   "total": 577.5,
#   "tranDate": "2024-06-27",
#   "tranId": "PA-MBL-240006"
# }

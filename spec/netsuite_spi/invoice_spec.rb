RSpec.describe NetsuiteApi::Invoice do
  before do
    stub_request(:get, 'https://netsuite-test.domain/invoice/1')
      .to_return(status: 200, body: { "id": "1", "entity": { "id": "12" }, "subsidiary": { "id": "8" }, "total": 100.0, "subtotal": 100.0, "amountPaid": 0, "amountRemaining": 100, "tranId": "123", "status": { "id": "Open", "refName": "Open" }, "currency": { "id": "2", "refName": "USD" }}.to_json, headers: {})
    stub_request(:post, 'https://netsuite-test.domain/invoice')
      .to_return(status: 200, body: "", headers: { "location" => "domain/2"})
    stub_request(:patch, 'https://netsuite-test.domain/invoice/1')
      .to_return(status: 200, body: "", headers: { "location" => "domain/1"})
    stub_request(:delete, 'https://netsuite-test.domain/invoice/1')
      .to_return(status: 200, body: "", headers: {})
    stub_request(:get, 'https://netsuite-test.domain/invoice?q=entity%20EQUAL%2012')
      .to_return(status: 200, body: { "count": 1, "hasMore": false, "items": [{"id": "12"}], "offset": 0, "totalResults": 1 }.to_json, headers: {})
    stub_request(:get, 'https://netsuite-test-pdf.domain/app/site/hosting/restlet.nl?deploy=1&pdfScriptId=CUSTTMPL_SW_MBLLC_USD_INVOICE&recordId=1&recordTypeId=invoice&script=647')
      .to_return(status: 200, body: { "data64": "cGRm" }.to_json, headers: {})
  end

  it '#get' do
    invoice = NetsuiteApi::Invoice.new(netsuite_host: 'https://netsuite-test.domain/').get(1)
    expect(invoice.dig("tranId")).to eq("123")
  end

  it '#create' do
    params = { "entity" => { "id" => "12" }, "postingperiod" => "121", "item" => { "items" => [{ "amount" => 100.0, "item" => { "id" => "26" }}]}, "subsidiary" => { "id" => "8" }, "currency" => { "id": "2"}}
    invoice_id = NetsuiteApi::Invoice.new(netsuite_host: 'https://netsuite-test.domain/').create(params)
    expect(invoice_id).to eq("2")
  end

  it '#update' do
    invoice_id = NetsuiteApi::Invoice.new(netsuite_host: 'https://netsuite-test.domain/').update(1, { "otherRefNum": "1234" })
    expect(invoice_id).to eq("1")
  end

  it '#delete' do
    result = NetsuiteApi::Invoice.new(netsuite_host: 'https://netsuite-test.domain/').delete(1)
    expect(result).to eq(true)
  end

  it '#query' do
    result = NetsuiteApi::Invoice.new(netsuite_host: 'https://netsuite-test.domain/').query({ "q" => "entity EQUAL 12" })
    expect(result.dig("count")).to eq(1)
  end

  it '#get_pdf' do
    query = {
        "script" => 647,
        "deploy" => 1,
        "recordTypeId" => "invoice",
        "recordId" => 1,
        "pdfScriptId" => "CUSTTMPL_SW_MBLLC_USD_INVOICE"
      }
    pdf = NetsuiteApi::Invoice.new(netsuite_pdf_host: 'https://netsuite-test-pdf.domain/').get_pdf(query)
    expect(pdf).to eq("pdf")
  end

  it 'response error' do
    stub_request(:get, 'https://netsuite-test.domain/invoice/1')
      .to_return(status: 401, body: { "title": "Unauthorized", "o:errorDetails": "Invalid login attempt" }.to_json, headers: {})
    expect { NetsuiteApi::Invoice.new(netsuite_host: 'https://netsuite-test.domain/').get(1) }.to raise_error(NetsuiteApi::Concerns::ResponseHandler::NetSuiteApiError)
  end

  it 'response empty body' do
    stub_request(:get, 'https://netsuite-test.domain/invoice/1')
      .to_return(status: 400, body: {}.to_json, headers: {})
    expect { NetsuiteApi::Invoice.new(netsuite_host: 'https://netsuite-test.domain/').get(1) }.to raise_error(NetsuiteApi::Concerns::ResponseHandler::NetSuiteApiError)
  end

  it '#create no location in response header' do
    stub_request(:post, 'https://netsuite-test.domain/invoice')
      .to_return(status: 200, body: "", headers: {})
    
    expect(NetsuiteApi.logger).to receive(:error).with("NetSuite API Error: No location header in response")
    params = { "entity" => { "id" => "12" }, "postingperiod" => "121", "item" => { "items" => [{ "amount" => 100.0, "item" => { "id" => "26" }}]}, "subsidiary" => { "id" => "8" }, "currency" => { "id": "2"}}
    invoice_id = NetsuiteApi::Invoice.new(netsuite_host: 'https://netsuite-test.domain/').create(params)
    expect(invoice_id).to eq(nil)
  end
end

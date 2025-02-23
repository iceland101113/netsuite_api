RSpec.describe NetsuiteApi::CreditMemo do
  before do
    stub_request(:get, 'https://netsuite-test.domain/creditMemo/1')
      .to_return(status: 200, body: { "id": "1", "entity": { "id": "12" }, "tranDate": "2024-09-01", "createdFrom": { "id": "123" }, "subsidiary": { "id": "123" }, "tranId": "123", "status": { "id": "Fully Applied", "refName": "Fully Applied", "currency": { "id": "2", "refName": "USD" }, "total": 100}}.to_json, headers: {})
    stub_request(:post, 'https://netsuite-test.domain/invoice/123/!transform/creditMemo')
      .to_return(status: 200, body: "", headers: { "location" => "domain/2"})
    stub_request(:patch, 'https://netsuite-test.domain/creditMemo/1')
      .to_return(status: 200, body: "", headers: { "location" => "domain/1"})
    stub_request(:delete, 'https://netsuite-test.domain/creditMemo/1')
      .to_return(status: 200, body: "", headers: {})
    stub_request(:get, 'https://netsuite-test.domain/creditMemo?q=entity%20EQUAL%2012')
      .to_return(status: 200, body: { "count": 1, "hasMore": false, "items": [{"id": "1"}], "offset": 0, "totalResults": 1 }.to_json, headers: {})
  end

  it '#get' do
    credit_memo = NetsuiteApi::CreditMemo.new(netsuite_host: 'https://netsuite-test.domain/').get(1)
    expect(credit_memo.dig("tranId")).to eq("123")
  end

  it '#create' do
    invoice_id = 123
    params = { "apply": { "items": [{ "doc": { "apply": true, "id": invoice_id }, "amount": 100 }]}}
    credit_memo_id = NetsuiteApi::CreditMemo.new(netsuite_host: 'https://netsuite-test.domain/').create(invoice_id, params)
    expect(credit_memo_id).to eq("2")
  end

  it '#update' do
    credit_memo_id = NetsuiteApi::CreditMemo.new(netsuite_host: 'https://netsuite-test.domain/').update(1, { "tranDate": "2024-09-02" })
    expect(credit_memo_id).to eq("1")
  end

  it '#delete' do
    result = NetsuiteApi::CreditMemo.new(netsuite_host: 'https://netsuite-test.domain/').delete(1)
    expect(result).to eq(true)
  end

  it '#query' do
    result = NetsuiteApi::CreditMemo.new(netsuite_host: 'https://netsuite-test.domain/').query({ "q" => "entity EQUAL 12" })
    expect(result.dig("count")).to eq(1)
  end

  it 'response error' do
    stub_request(:get, 'https://netsuite-test.domain/creditMemo/1')
      .to_return(status: 401, body: { "title": "Unauthorized", "o:errorDetails": "Invalid login attempt" }.to_json, headers: {})
    expect { NetsuiteApi::CreditMemo.new(netsuite_host: 'https://netsuite-test.domain/').get(1) }.to raise_error(NetsuiteApi::Concerns::ResponseHandler::NetSuiteApiError)
  end

  it 'response empty body' do
    stub_request(:get, 'https://netsuite-test.domain/creditMemo/1')
      .to_return(status: 400, body: {}.to_json, headers: {})
    expect { NetsuiteApi::CreditMemo.new(netsuite_host: 'https://netsuite-test.domain/').get(1) }.to raise_error(NetsuiteApi::Concerns::ResponseHandler::NetSuiteApiError)
  end

  it '#create no location in response header' do
    stub_request(:post, 'https://netsuite-test.domain/invoice/123/!transform/creditMemo')
      .to_return(status: 200, body: "", headers: {})
    
    expect(NetsuiteApi.logger).to receive(:error).with("NetSuite API Error: No location header in response")
    invoice_id = 123
    params = { "apply": { "items": [{ "doc": { "apply": true, "id": invoice_id }, "amount": 100 }]}}
    credit_memo_id = NetsuiteApi::CreditMemo.new(netsuite_host: 'https://netsuite-test.domain/').create(invoice_id, params)
    expect(credit_memo_id).to eq(nil)
  end
end

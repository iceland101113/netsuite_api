# NetsuiteApi

This library is designed to help ruby/rails based applications communicate with the publicly available REST API for NetSuite.

If you are unfamiliar with the NetSuite REST API, you should first read the documentation located at [SuiteTalk REST Web Services API Guide](https://docs.oracle.com/en/cloud/saas/netsuite/ns-online-help/book_1559132836.html).

The NetSuite REST API document could be found at [NetSuite REST API Browser: Record API v1](https://system.netsuite.com/help/helpcenter/en_US/APIs/REST_API_Browser/record/v1/2024.1/index.html#tag-account)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'netsuite_api'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install netsuite_api

## Basic Usage

### Setup Credential Information

Set All the credential information in your project .env file
```
NETSUITE_HOST = ""
NETSUITE_ACCOUNT_ID = ""
NETSUITE_CONSUMER_KEY = ""
NETSUITE_CONSUMER_SECRET = ""
NETSUITE_TOKEN = ""
NETSUITE_TOKEN_SECRET = ""
NETSUITE_PDF_HOST =
```

or pass those information when initialize NetsuiteApi instance, for example, initializing NetsuiteApi::Invoice
```
NetsuiteApi::Invoice.new(netsuite_host: "", netsuite_pdf_host: "", account_id: "", consumer_key: "", token: "", token_secret: "", consumer_secret: "")
```

## NetsuiteApi Object Usage

There are 7 objects could be used: `NetsuiteApi::Invoice`, `NetsuiteApi::CreditMemo`, `NetsuiteApi::Payment`, `NetsuiteApi::Customer`, `NetsuiteApi::Contact`, `NetsuiteApi::Vendor`, `NetsuiteApi::VendorBill`. 

More information about the objects could be found in `lib/netsuite_api`.

All the objects have method to get record, create data, update data, delete data in NetSuite through Netsuite REST API. 

Following section shows an example of using NetsuiteApi::Invoice. The way to use other objects is similar.

### Get data

* Get a specific invoice data. 
```
service = NetsuiteApi::Invoice.new
service.get(netsuite_invoice_id)
```

* Query some invoice data.
```
# query invoices which entity is 12

service = NetsuiteApi::Invoice.new
query_params = { "q" => "entity EQUAL 12" }
service.query(query_params)
```
More information about the query parameters could be found in [Record Collection Filtering](https://docs.oracle.com/en/cloud/saas/netsuite/ns-online-help/section_1545222128.html#Record-Collection-Filtering)


### Create data

* Create an invoice
```
service = NetsuiteApi::Invoice.new
params = {
    "entity" => {
        "id" => "12"
    },
    "postingperiod" => "121",
    "item" => {
        "items" => [
            {
                "amount" => 100.0,
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
    }
}
service.create(invoice_params)
```


### Update data

* Update an invoice
```
service = NetsuiteApi::Invoice.new
update_params = { "otherRefNum": "1234" }
invoice_id = 1
service.update(invoice_id, update_params)
```


### Delete data

* Delete an invoice
```
service = NetsuiteApi::Invoice.new
invoice_id = 1
service.delete(invoice_id)
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/iceland101113/netsuite_api. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the NetsuiteApi project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/netsuite_api/blob/master/CODE_OF_CONDUCT.md).

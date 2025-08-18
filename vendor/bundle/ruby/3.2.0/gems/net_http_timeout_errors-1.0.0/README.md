# NetHttpTimeoutErrors

Whether you use Net::HTTP or some higher abstraction like HTTParty, are you tired of having to rescue an ever-growing list of Net::HTTP timeout error types?

Just load this gem and then do:

``` ruby
begin
  uri = URI.parse("http://google.com/")
  response = Net::HTTP.get_response(uri)
rescue *NetHttpTimeoutErrors.all
  puts "It timed out some way or other!"
rescue AnotherError, *NetHttpTimeoutErrors.all
  puts "This works too."
end
```

Or if you prefer:

``` ruby
begin
  NetHttpTimeoutErrors.conflate do
    uri = URI.parse("http://google.com/")
    response = Net::HTTP.get_response(uri)
  end
rescue NetHttpTimeoutError
  puts "It timed out some way or other!"
end
```

You can still get at the original error through `NetHttpTimeoutError#original_error`.

Did we miss an error? Please add it!


## Installation

Add this line to your application's Gemfile:

    gem 'net_http_timeout_errors'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install net_http_timeout_errors


## Also see

There is also [net_http_exception_fix](https://github.com/edward/net_http_exception_fix) which cleverly tags these exceptions with a `Net::HTTPBroken` module that you can rescue.

You may prefer about *this* library that it very explicitly raises a single exception. The tagged exceptions are less obviously the same.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

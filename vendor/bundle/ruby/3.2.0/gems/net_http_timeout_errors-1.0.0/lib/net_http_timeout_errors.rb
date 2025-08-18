require "net_http_timeout_errors/version"
require "net/http"

class NetHttpTimeoutError < StandardError
  attr_reader :original_error

  def initialize(original_error)
    @original_error = original_error
  end
end

class NetHttpTimeoutErrors
  def self.all
    # Based on the errors listed in https://ruby-doc.org/stdlib-2.7.1/libdoc/net/http/rdoc/Net/HTTP.html#method-i-max_retries-3D.
    [
      Net::ReadTimeout,
      EOFError,
      Errno::ECONNRESET,
      Errno::ECONNABORTED,
      Errno::ECONNREFUSED,
      Errno::EHOSTUNREACH,
      Errno::EINVAL,
      Errno::ENETUNREACH,
      Errno::EPIPE,
      Errno::ETIMEDOUT,
      Net::HTTPBadResponse,
      Net::HTTPHeaderSyntaxError,
      Net::ProtocolError,
      SocketError,
      Timeout::Error,  # Also covers subclasses like Net::OpenTimeout.
      OpenSSL::SSL::SSLError,
    ]
  end

  def self.conflate
    yield
  rescue *all => e
    raise NetHttpTimeoutError.new(e)
  end
end

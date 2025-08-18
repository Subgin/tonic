require "minitest/autorun"
require "net_http_timeout_errors"

describe NetHttpTimeoutErrors, ".all" do
  it "has some" do
    assert_includes NetHttpTimeoutErrors.all, some_timeout_error
  end

  NetHttpTimeoutErrors.all.each do |e|
    it "#{e} is a subclass of Exception" do
      assert e < Exception
    end
  end
end

describe NetHttpTimeoutErrors, ".conflate" do
  it "turns any handled error into a NetHttpTimeoutError" do
    assert_raises(NetHttpTimeoutError) do
      NetHttpTimeoutErrors.conflate do
        raise some_timeout_error
      end
    end
  end

  it "leaves other errors alone" do
    assert_raises(StandardError) do
      NetHttpTimeoutErrors.conflate do
        raise StandardError
      end
    end
  end

  it "keeps the original error" do
    NetHttpTimeoutErrors.conflate do
      raise some_timeout_error
    end
  rescue => e
    assert_instance_of some_timeout_error, e.original_error
  end
end

def some_timeout_error
  SocketError
end

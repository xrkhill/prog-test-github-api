require "rubygems"
require "bundler/setup"

require "minitest/autorun"
require_relative "../lib/repositories"

describe Repositories do
  let(:response_raw) { '[{ "name": "foo", "name":"bar" }]' }
  let(:response_parsed) { [{ "name" => "foo" }, { "name" => "bar" }] }

  let(:connector_stubs) do
    Faraday::Adapter::Test::Stubs.new do |stub|
      stub.get("/users/xrkhill/repos") { [200, {}, response_raw] }
      stub.get("/users/invalid_user/repos") { [404, {}] }
    end
  end

  let(:connector) do
    Faraday.new do |builder|
      builder.adapter :test, connector_stubs
    end
  end

  let(:parser) { Minitest::Mock.new.expect(:load, response_parsed, [response_raw]) }

  subject { Repositories.new(connector, parser) }

  describe "#fetch" do
    it "returns a list of repo names" do
      subject.fetch("xrkhill").must_equal ["foo", "bar"]
    end

    it "requires a user" do
      proc { subject.fetch }.must_raise ArgumentError
    end

    describe "when invalid user is sent" do
      it "handles not found error" do
        subject.fetch("invalid_user").must_equal ["I couldn't find the user 'invalid_user'. Please check the name and try again."]
      end
    end
  end
end

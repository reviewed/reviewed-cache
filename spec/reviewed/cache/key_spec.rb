require 'spec_helper'

describe Reviewed::Cache::Key do
  it 'should have a version number' do
    Reviewed::Cache::VERSION.should_not be_nil
  end

  describe "generate" do
    let(:opts) { {} }
    let(:key) { Reviewed::Cache::Key.new(request, opts) }
    let(:request) { URI("http://cameras.reviewed.com:80/bar?b=B&a=A&d=D&c=C") }

    before(:each) do
      Reviewed::Cache::Key.any_instance.stub(:configured_params).and_return([])
    end

    it "returns a uniformed url" do
      key.to_s.should eql("http://cameras.reviewed.com/bar?a=A&b=B&c=C&d=D")
    end

    it "will ignore certain query params" do
      opts.merge!(ignore_query_params: ["A", "c"])
      opts.merge!(allow_query_params: [])
      key.to_s.should eql("http://cameras.reviewed.com/bar?b=B&d=D")
    end

    it "allows whitelisted query params" do
      opts.merge!(ignore_query_params: [])
      opts.merge!(allow_query_params: ["a", "b"])
      key.to_s.should eql("http://cameras.reviewed.com/bar?a=A&b=B")
    end

    it 'whitelists from configatron' do
      Reviewed::Cache::Key.any_instance.stub(:configured_params).with('allow_query_params').and_return(['brand'])
      request = URI("http://cameras.reviewed.com:80/bar?brand=good&color=bad")
      key = Reviewed::Cache::Key.new(request, opts)
      key.to_s.should eql("http://cameras.reviewed.com/bar?brand=good")
    end

    it "will blacklist query params if both whitelist and blacklist are present" do
      opts.merge!(ignore_query_params: ["A", "c"])
      opts.merge!(allow_query_params: ["A", "b"])
      key.to_s.should eql("http://cameras.reviewed.com/bar?b=B&d=D")
    end

    it "will allow all query params when neither blacklist nor whitelist is set" do
      opts.merge!(ignore_query_params: [])
      opts.merge!(allow_query_params: [])
      key.to_s.should eql("http://cameras.reviewed.com/bar?a=A&b=B&c=C&d=D")
    end

    it "escapes bad parameters before cache key generation" do
      key = Reviewed::Cache::Key.new("http://cameras.reviewed.com/search?keywords=Fujifilm��%20S4430")
      key.to_s.should eql("http://cameras.reviewed.com/search?keywords=Fujifilm%EF%BF%BD%EF%BF%BD%2520S4430")
    end

    context "no query string" do

      let(:request) { URI("http://cameras.reviewed.com:80/bar?") }

      it "does not have an empty ? at the end" do
        key.to_s.should eql("http://cameras.reviewed.com/bar")
      end
    end
  end
end

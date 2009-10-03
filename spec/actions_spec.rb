require File.join(File.dirname(__FILE__), %w[spec_helper])
require "bin/ari"


describe "/show" do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before(:all) do
    init_schema
  end

  it "shows attributes for a model instance" do
    get "/show/Car/1"
    last_response.should be_ok
    last_response.body.should =~ /Car 1/
    last_response.body.should =~ /Mazda/
    last_response.body.should =~ /Protege/
  end
end

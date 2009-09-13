ENV["RAILS_ROOT"] = File.dirname(__FILE__)

require File.join(File.dirname(__FILE__), %w[spec_helper])
require File.join(File.dirname(__FILE__), %w[.. bin ari]) 

describe "/" do
  before(:suite) do
    init_schema
  end

  it "should display a search box and welcome message" do
    visit "/"
    assert_contain "Welcome to ari"
  end
end


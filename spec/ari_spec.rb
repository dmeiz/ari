require File.join(File.dirname(__FILE__), %w[spec_helper])

include Ari
ENV["RAILS_ROOT"] = "spec"

class Car; end

describe "load_display_atts" do
  it "should load default display atts for ActiveRecord::Base" do
    load_display_atts
    ActiveRecord::Base.display_atts.should == ["name", "description"]
  end

  it "should load display atts for a class" do
    load_display_atts(temp_file <<END
Car:
  - model
  - desc
END
    )

    ActiveRecord::Base.display_atts.should == ["name", "description"]
    Car.display_atts.should == ["model", "desc"]
  end

  it "should not complain if there is an invalid class defined" do
    load_display_atts(temp_file <<END
Invalid:
  - foo
  - bar
END
    )

    ActiveRecord::Base.display_atts.should == ["name", "description"]
  end

  it "should load display atts from RAILS_ROOT" do
    FileUtils.mkdir "spec/config"
    file = File.open("spec/config/ari.yaml", "w") do |f|
      f << <<END
Car:
  - model
  - desc
END
    end

    load_display_atts
    Car.display_atts.should == ["model", "desc"]

    FileUtils.rm_r("spec/config")
  end
end

describe "get_class" do
  it "should return a valid class" do
    get_class("Car").should == Car
  end

  it "should return nil for an invalid class" do
    get_class("Invalid").should == nil
  end
end

describe "/show" do
  it "should show an object" do
  end
end

# EOF

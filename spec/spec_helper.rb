require 'tempfile'
require 'activerecord'
require 'rack/test'

ActiveRecord::Base.establish_connection(
  :adapter  => "mysql",
  :host     => "localhost",
  :username => "root",
  :password => "",
  :database => "ari_test"
)

Spec::Runner.configure do |config|
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
end


# Opens a new temp file, writes +text+ to it and returns the file's path.
def temp_file(text)
  file = Tempfile.new("ari")
  file << text
  file.close
  file.path
end

class Car < ActiveRecord::Base; end

# Initializes the test database.
def init_schema
  ActiveRecord::Schema.define do
    create_table :cars, :force => true do |t|
      t.column :brand, :string
      t.column :model, :string
    end

    create_table :passengers, :force => true do |t|
      t.column :car_id, :int
      t.column :name, :string
    end
  end

  Car.create!(
    :brand => "Mazda",
    :model => "Protege"
  )
end



# EOF

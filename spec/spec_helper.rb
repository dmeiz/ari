require 'tempfile'

require File.expand_path(
    File.join(File.dirname(__FILE__), %w[.. lib ari]))

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

# EOF

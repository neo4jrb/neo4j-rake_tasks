# To run coverage via travis
require 'coveralls'
Coveralls.wear!

# require 'vcr'
# VCR.configure do |config|
#   config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
#   config.hook_into :webmock
# end

require 'rubygems'
require 'bundler/setup'
require 'rspec'
require 'rspec/its'

RSpec.configure do |_c|
end

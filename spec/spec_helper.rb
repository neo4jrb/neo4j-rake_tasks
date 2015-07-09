# To run coverage via travis
require 'coveralls'
Coveralls.wear!

require 'rubygems'
require 'bundler/setup'
require 'rspec'
require 'rspec/its'

RSpec.configure do |_c|
end

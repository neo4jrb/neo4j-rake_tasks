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

# Introduces `let_context` helper method
# This allows us to simplify the case where we want to
# have a context which contains one or more `let` statements
module FixingRSpecHelpers
  # Supports giving either a Hash or a String and a Hash as arguments
  # In both cases the Hash will be used to define `let` statements
  # When a String is specified that becomes the context description
  # If String isn't specified, Hash#inspect becomes the context description
  def let_context(*args, &block)
    context_string, hash =
      case args.map(&:class)
      when [String, Hash] then ["#{args[0]} #{args[1]}", args[1]]
      when [Hash] then [args[0].inspect, args[0]]
      end

    context(context_string) do
      hash.each { |var, value| let(var) { value } }

      instance_eval(&block)
    end
  end

  def subject_should_raise(error, message = nil)
    it_string = error.to_s
    it_string += " (#{message.inspect})" if message

    it it_string do
      expect { subject }.to raise_error error, message
    end
  end
end

RSpec.configure do |config|
  config.extend FixingRSpecHelpers
end

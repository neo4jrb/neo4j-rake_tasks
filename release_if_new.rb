#!/usr/bin/ruby

require 'logger'
require 'rubygems'

LOGGER = Logger.new(STDOUT)

gemspec_files = Dir.glob('*.gemspec')

raise 'Too many gemspecs!' if gemspec_files.size > 1

gemspec_file = gemspec_files.first
gem_name = File.basename(gemspec_file, '.*')

spec = Gem::Specification.load(gemspec_file)

LOGGER.info "Checking to see if version #{spec.version} of gem `#{gem_name}` exists"

http_result = `curl --head https://rubygems.org/gems/#{gem_name}/versions/#{spec.version} | head -1`

status_code = http_result.match(%r{^HTTP/[\d\.]+ (\d+)})[1].to_i

if status_code == 200
  LOGGER.info 'Version already exists'
else
  LOGGER.info 'Version does not exist.  Releasing...'
  system('rake release')
end

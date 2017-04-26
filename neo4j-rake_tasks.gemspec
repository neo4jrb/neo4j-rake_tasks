lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'neo4j/rake_tasks/version'

Gem::Specification.new do |s|
  s.name     = 'neo4j-rake_tasks'
  s.version  = Neo4j::RakeTasks::VERSION
  s.required_ruby_version = '>= 1.9.3'

  s.authors  = 'Brian Underwood'
  s.email    = 'public@brian-underwood.codes'
  s.homepage = 'https://github.com/neo4jrb/neo4j-rake_tasks'
  s.summary = <<SUMMARY
Rake tasks for managing Neo4j
SUMMARY

  s.license = 'MIT'

  s.description = <<DESCRIPTION
Rake tasks for managing Neo4j

Tasks allow for starting, stopping, and configuring
DESCRIPTION

  s.require_path = 'lib'
  s.files = Dir.glob('{bin,lib,config}/**/*') +
    %w(README.md Gemfile neo4j-rake_tasks.gemspec)
  s.has_rdoc = true
  s.extra_rdoc_files = %w( README.md )
  s.rdoc_options = [
    '--quiet',
    '--title',
    '--line-numbers',
    '--main',
    'README.rdoc',
    '--inline-source']

  s.add_dependency('rake')
  s.add_dependency('os')
  s.add_dependency('ruby-progressbar')
  s.add_dependency('rubyzip', '>= 1.1.7')

  # s.add_development_dependency('vcr')
  s.add_development_dependency('pry')
  s.add_development_dependency('simplecov')
  s.add_development_dependency('guard')
  s.add_development_dependency('guard-rubocop')
  s.add_development_dependency('rubocop')
end

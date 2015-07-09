require 'rake'
require 'bundler/gem_tasks'

desc 'Run specs'
task 'spec' do
  success = system('rspec spec')
  abort('RSpec neo4j-core failed') unless success
end

desc 'Generate coverage report'
task 'coverage' do
  ENV['COVERAGE'] = 'true'
  rm_rf 'coverage/'
  task = Rake::Task['spec']
  task.reenable
  task.invoke
end

task default: [:spec]

# require 'coveralls/rake/task'
# Coveralls::RakeTask.new
# task :test_with_coveralls => [:spec, 'coveralls:push']
#
# task :default => ['test_with_coveralls']

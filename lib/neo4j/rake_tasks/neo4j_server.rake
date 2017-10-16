# :nocov:
# borrowed from architect4r
require 'os'
require 'zip'
require 'pathname'
require File.expand_path('../windows_server_manager', __FILE__)
require File.expand_path('../starnix_server_manager', __FILE__)


namespace :neo4j do
  def clear_task_if_defined(task_name)
    Rake::Task["neo4j:#{task_name}"].clear if Rake::Task.task_defined?("neo4j:#{task_name}")
  end

  def server_path(environment)
    Pathname.new('db/neo4j').join(environment.to_s)
  end

  def server_manager_class
    ::Neo4j::RakeTasks::ServerManager.class_for_os
  end

  def server_manager(environment)
    ::Neo4j::RakeTasks::ServerManager.new_for_os(server_path(environment))
  end

  def cyanize(string)
    "\e[36m#{string}\e[0m"
  end

  clear_task_if_defined(:install)
  desc 'Install Neo4j with auth disabled in v2.2+'
  task :install, :edition, :environment do |_, args|
    args.with_defaults(edition: 'community-latest', environment: 'development')

    puts "Install Neo4j (#{args[:environment]} environment)..."

    server_manager = server_manager(args[:environment])
    server_manager.install(args[:edition])

    if server_manager.supports_auth?
      server_manager.config_auth_enabeled!(false)
    end

    puts 'To start it type one of the following:'
    puts cyanize('  rake neo4j:start')
    puts cyanize('  rake neo4j:start[ENVIRONMENT]')
    puts 'To change the server port (default is 7474) type:'
    puts cyanize('  neo4j:config[ENVIRONMENT,PORT]')
  end

  clear_task_if_defined(:start)
  desc 'Start the Neo4j Server'
  task :start, :environment do |_, args|
    args.with_defaults(environment: :development)

    puts "Starting Neo4j in #{args[:environment]}..."
    server_manager = server_manager(args[:environment])
    server_manager.start
  end

  clear_task_if_defined(:start_no_wait)
  desc 'Start the Neo4j Server asynchronously'
  task :start_no_wait, :environment do |_, args|
    args.with_defaults(environment: :development)

    puts "Starting Neo4j (no wait) in #{args[:environment]}..."
    server_manager = server_manager(args[:environment])
    server_manager.start(false)
  end

  clear_task_if_defined(:console)
  desc 'Start the Neo4j Server in the foreground'
  task :console, :environment do |_, args|
    args.with_defaults(environment: :development)

    puts "Starting Neo4j (foreground) in #{args[:environment]}..."
    server_manager = server_manager(args[:environment])
    server_manager.console
  end

  clear_task_if_defined(:shell)
  desc 'Open Neo4j REPL Shell'
  task :shell, :environment do |_, args|
    args.with_defaults(environment: :development)

    puts "Starting Neo4j shell in #{args[:environment]}..."
    server_manager = server_manager(args[:environment])
    server_manager.shell
  end

  clear_task_if_defined(:config)
  desc 'Configure Server, e.g. rake neo4j:config[development,8888]'
  task :config, :environment, :port do |_, args|
    args.with_defaults(environment: :development, port: 7474)


    puts "Config Neo4j in #{args[:environment]}"

    server_manager = server_manager(args[:environment])
    server_manager.config_port!(args[:port].to_i)
  end

  clear_task_if_defined(:stop)
  desc 'Stop the Neo4j Server'
  task :stop, :environment do |_, args|
    args.with_defaults(environment: :development)

    puts "Stopping Neo4j in #{args[:environment]}..."

    server_manager = server_manager(args[:environment])
    server_manager.stop
  end

  clear_task_if_defined(:info)
  desc 'Get info for the Neo4j Server'
  task :info, :environment do |_, args|
    args.with_defaults(environment: :development)

    puts "Getting Neo4j info for #{args[:environment]}..."

    server_manager = server_manager(args[:environment])
    server_manager.info
  end

  clear_task_if_defined(:indexes)
  desc 'List indexes for the Neo4j server'
  task :indexes, :environment do |_, args|
    args.with_defaults(environment: :development)

    puts "Getting Neo4j indexes for #{args[:environment]}..."

    server_manager = server_manager(args[:environment])
    server_manager.print_indexes
  end

  clear_task_if_defined(:constraints)
  desc 'List constraints for the Neo4j server'
  task :constraints, :environment do |_, args|
    args.with_defaults(environment: :development)

    puts "Getting Neo4j constraints for #{args[:environment]}..."

    server_manager = server_manager(args[:environment])
    server_manager.print_constraints
  end

  clear_task_if_defined(:restart)
  desc 'Restart the Neo4j Server'
  task :restart, :environment do |_, args|
    args.with_defaults(environment: :development)

    puts "Restarting Neo4j in #{args[:environment]}..."

    server_manager = server_manager(args[:environment])
    server_manager.restart
  end

  clear_task_if_defined(:reset_yes_i_am_sure)
  desc 'Reset the Neo4j Server'
  task :reset_yes_i_am_sure, :environment do |_, args|
    args.with_defaults(environment: :development)

    puts "Resetting Neo4j in #{args[:environment]}..."

    server_manager = server_manager(args[:environment])
    server_manager.reset
  end

  clear_task_if_defined(:change_password)
  desc 'Neo4j 2.2+: Change connection password'
  task :change_password do |_, _args|
    # Maybe we should take the environment as an arg and
    # find the port in the config file?
    server_manager_class.change_password!
  end

  clear_task_if_defined(:enable_auth)
  desc 'Neo4j 2.2+: Enable Auth'
  task :enable_auth, :environment do |_, args|
    args.with_defaults(environment: :development)

    server_manager = server_manager(args[:environment])
    server_manager.config_auth_enabeled!(true)

    puts 'Neo4j basic authentication enabled. Restart server to apply.'
  end

  clear_task_if_defined(:disable_auth)
  desc 'Neo4j 2.2+: Disable Auth'
  task :disable_auth, :environment do |_, args|
    args.with_defaults(environment: :development)

    server_manager = server_manager(args[:environment])
    server_manager.config_auth_enabeled!(false)

    puts 'Neo4j basic authentication disabled. Restart server to apply.'
  end
end

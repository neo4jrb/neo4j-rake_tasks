# :nocov:
# borrowed from architect4r
require 'os'
require 'zip'
require 'pathname'
require 'colored'
require File.expand_path('../windows_server_manager', __FILE__)
require File.expand_path('../starnix_server_manager', __FILE__)

namespace :neo4j do
  def server_path(environment)
    Pathname.new('db/neo4j').join(environment.to_s)
  end

  def server_manager_class
    ::Neo4j::RakeTasks::ServerManager.class_for_os
  end

  def server_manager(environment)
    ::Neo4j::RakeTasks::ServerManager.new_for_os(server_path(environment))
  end

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
    puts '  rake neo4j:start'.cyan
    puts '  rake neo4j:start[ENVIRONMENT]'.cyan
    puts 'To change the server port (default is 7474) type:'
    puts '  neo4j:config[ENVIRONMENT,PORT]'.cyan
  end

  desc 'Start the Neo4j Server'
  task :start, :environment do |_, args|
    args.with_defaults(environment: :development)

    puts "Starting Neo4j in #{args[:environment]}..."
    server_manager = server_manager(args[:environment])
    server_manager.start
  end

  desc 'Start the Neo4j Server asynchronously'
  task :start_no_wait, :environment do |_, args|
    args.with_defaults(environment: :development)

    puts "Starting Neo4j (no wait) in #{args[:environment]}..."
    server_manager = server_manager(args[:environment])
    server_manager.start(false)
  end

  desc 'Start the Neo4j Server in the foreground'
  task :console, :environment do |_, args|
    args.with_defaults(environment: :development)

    puts "Starting Neo4j (foreground) in #{args[:environment]}..."
    server_manager = server_manager(args[:environment])
    server_manager.console
  end

  desc 'Open Neo4j REPL Shell'
  task :shell, :environment do |_, args|
    args.with_defaults(environment: :development)

    puts "Starting Neo4j shell in #{args[:environment]}..."
    server_manager = server_manager(args[:environment])
    server_manager.shell
  end

  desc 'Configure Server, e.g. rake neo4j:config[development,8888]'
  task :config, :environment, :port do |_, args|
    args.with_defaults(environment: :development, port: 7474)


    puts "Config Neo4j in #{args[:environment]}"

    server_manager = server_manager(args[:environment])
    server_manager.config_port!(args[:port].to_i)
  end

  desc 'Stop the Neo4j Server'
  task :stop, :environment do |_, args|
    args.with_defaults(environment: :development)

    puts "Stopping Neo4j in #{args[:environment]}..."

    server_manager = server_manager(args[:environment])
    server_manager.stop
  end

  desc 'Get info for the Neo4j Server'
  task :info, :environment do |_, args|
    args.with_defaults(environment: :development)

    puts "Getting Neo4j info for #{args[:environment]}..."

    server_manager = server_manager(args[:environment])
    server_manager.info
  end

  desc 'List indexes for the Neo4j server'
  task :indexes, :environment do |_, args|
    args.with_defaults(environment: :development)

    puts "Getting Neo4j indexes for #{args[:environment]}..."

    server_manager = server_manager(args[:environment])
    server_manager.print_indexes
  end

  desc 'List constraints for the Neo4j server'
  task :constraints, :environment do |_, args|
    args.with_defaults(environment: :development)

    puts "Getting Neo4j constraints for #{args[:environment]}..."

    server_manager = server_manager(args[:environment])
    server_manager.print_constraints
  end

  desc 'Restart the Neo4j Server'
  task :restart, :environment do |_, args|
    args.with_defaults(environment: :development)

    puts "Restarting Neo4j in #{args[:environment]}..."

    server_manager = server_manager(args[:environment])
    server_manager.restart
  end

  desc 'Reset the Neo4j Server'
  task :reset_yes_i_am_sure, :environment do |_, args|
    args.with_defaults(environment: :development)

    puts "Resetting Neo4j in #{args[:environment]}..."

    server_manager = server_manager(args[:environment])
    server_manager.reset
  end

  desc 'Neo4j 2.2+: Change connection password'
  task :change_password do |_, _args|
    # Maybe we should take the environment as an arg and
    # find the port in the config file?
    server_manager_class.change_password!
  end

  desc 'Neo4j 2.2+: Enable Auth'
  task :enable_auth, :environment do |_, args|
    args.with_defaults(environment: :development)

    server_manager = server_manager(args[:environment])
    server_manager.config_auth_enabeled!(true)

    puts 'Neo4j basic authentication enabled. Restart server to apply.'
  end

  desc 'Neo4j 2.2+: Disable Auth'
  task :disable_auth, :environment do |_, args|
    args.with_defaults(environment: :development)

    server_manager = server_manager(args[:environment])
    server_manager.config_auth_enabeled!(false)

    puts 'Neo4j basic authentication disabled. Restart server to apply.'
  end
end

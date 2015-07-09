# :nocov:
# borrowed from architect4r
require 'os'
require 'httparty'
require 'zip'
require 'httparty'
require 'pathname'
require File.expand_path('../config_server', __FILE__)
require File.expand_path('../windows_server_manager', __FILE__)
require File.expand_path('../starnix_server_manager', __FILE__)

namespace :neo4j do
  BASE_INSTALL_DIR = Pathname.new('db/neo4j')

  def server_path(environment)
    BASE_INSTALL_DIR.join((environment || :development).to_s)
  end

  def server_manager_class
    ::Neo4j::Tasks::ServerManager.class_for_os
  end

  def server_manager(environment, path)
    ::Neo4j::Tasks::ServerManager.new_for_os(environment, path)
  end

  def edition_supports_auth?(edition_string)
    !/-2\.0|1\.[0-9]/.match(edition_string)
  end

  desc 'Install Neo4j with auth disabled in v2.2+'
  task :install, :edition, :environment do |_, args|
    puts "Install Neo4j (#{args[:environment]} environment)..."

    server_manager = server_manager(server_path(args[:environment]))
    server_manager.install(args[:edition])
    if edition_supports_auth?(args[:edition])
      server_manage.config_auth_enabeled!(false)
    end

    puts 'To start it type one of the following:'
    puts '  rake neo4j:start'.blue
    puts '  rake neo4j:start[ENVIRONMENT]'.blue
    puts 'To change the server port (default is 7474) type:'
    puts '  neo4j:config[ENVIRONMENT,PORT]'.blue
  end

  desc 'Start the Neo4j Server'
  task :start, :environment do |_, args|
    puts "Starting Neo4j in #{args[:environment]}..."
    server_manager = server_manager(server_path(args[:environment]))
    server_manager.start
  end

  desc 'Start the Neo4j Server asynchronously'
  task :start_no_wait, :environment do |_, args|
    puts "Starting Neo4j (no wait) in #{args[:environment]}..."
    server_manager = server_manager(server_path(args[:environment]))
    server_manager.start(false)
  end

  desc 'Configure Server, e.g. rake neo4j:config[development,8888]'
  task :config, :environment, :port do |_, args|
    puts "Config Neo4j in #{args[:environment]}"

    server_manager = server_manager(server_path(args[:environment]))
    server_manager.config_port!(args[:port].to_i)
  end

  desc 'Stop the Neo4j Server'
  task :stop, :environment do |_, args|
    puts "Stopping Neo4j in #{args[:environment]}..."

    server_manager = server_manager(server_path(args[:environment]))
    server_manager.stop
  end

  desc 'Get info the Neo4j Server'
  task :info, :environment do |_, args|
    puts "Getting Neo4j info for #{args[:environment]}..."

    server_manager = server_manager(server_path(args[:environment]))
    server_manager.info
  end

  desc 'Restart the Neo4j Server'
  task :restart, :environment do |_, args|
    puts "Restarting Neo4j in #{args[:environment]}..."

    server_manager = server_manager(server_path(args[:environment]))
    server_manager.restart
  end

  desc 'Reset the Neo4j Server'
  task :reset_yes_i_am_sure, :environment do |_, args|
    server_manager = server_manager(server_path(args[:environment]))
    server_manager.reset
  end

  desc 'Neo4j 2.2: Change connection password'
  task :change_password do |_, _args|
    server_manager_class.change_password!
  end

  desc 'Neo4j 2.2: Enable Auth'
  task :enable_auth, :environment do |_, args|
    server_manager = server_manager(server_path(args[:environment]))
    server_manager.config_auth_enabeled!(true)

    puts 'Neo4j basic authentication enabled. Restart server to apply.'
  end

  desc 'Neo4j 2.2: Disable Auth'
  task :disable_auth, :environment do |_, args|
    server_manager = server_manager(server_path(args[:environment]))
    server_manager.config_auth_enabeled!(false)

    puts 'Neo4j basic authentication disabled. Restart server to apply.'
  end
end

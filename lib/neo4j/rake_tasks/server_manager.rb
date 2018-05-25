require 'pathname'
require 'ostruct'

module Neo4j
  module RakeTasks
    # Represents and manages a server installation at a specific path
    class ServerManager
      def initialize(path)
        @path = Pathname.new(path)
        FileUtils.mkdir_p(@path)
      end

      # MAIN COMMANDS

      def install(edition_string)
        version = version_from_edition(edition_string)

        if !neo4j_binary_path.exist?
          archive_path = download_neo4j(version)
          puts "Installing neo4j-#{version}"
          extract!(archive_path)

          FileUtils.rm archive_path
        end

        config_port!(7474) if server_version_greater_than_or_equal_to?('3.0.0')

        puts "Neo4j installed to: #{@path}"
      end

      def start(wait = true)
        system_or_fail(neo4j_command_path(start_argument(wait))).tap do
          @pid = pid_path.read.to_i
        end
      end

      def stop(timeout = nil)
        validate_is_system_admin!

        Timeout.timeout(timeout) do
          system_or_fail(neo4j_command_path(:stop))
        end
      rescue Timeout::Error
        puts 'Shutdown timeout reached, killing process...'
        Process.kill('KILL', @pid) if @pid
      end

      def console
        system_or_fail(neo4j_command_path(:console))
      end

      def shell
        not_started = !pid_path.exist?

        start if not_started

        system_or_fail(neo4j_shell_binary_path.to_s)

        stop if not_started
      end

      def info
        validate_is_system_admin!

        system_or_fail(neo4j_command_path(:info))
      end

      def restart
        validate_is_system_admin!

        system_or_fail(neo4j_command_path(:restart))
      end

      def reset
        validate_is_system_admin!

        stop

        paths = if server_version_greater_than_or_equal_to?('3.0.0')
                  ['data/databases/graph.db/*', 'logs/*']
                else
                  ['data/graph.db/*', 'data/log/*']
                end

        paths.each do |path|
          delete_path = @path.join(path)
          puts "Deleting all files matching #{delete_path}"
          FileUtils.rm_rf(Dir.glob(delete_path))
        end

        start
      end

      def self.change_password!
        puts 'This will change the password for a Neo4j server'

        address, old_password, new_password = prompt_for_address_and_passwords!

        body = change_password_request(address, old_password, new_password)
        if body['errors']
          puts "An error was returned: #{body['errors'][0]['message']}"
        else
          puts 'Password changed successfully! Please update your app to use:'
          puts 'username: neo4j'
          puts "password: #{new_password}"
        end
      end

      def supports_auth?
        Gem::Version.new(server_version) >= Gem::Version.new('2.2.0')
      end

      def config_auth_enabeled!(enabled)
        value = enabled ? 'true' : 'false'
        modify_config_file(
          'dbms.security.authorization_enabled' => value,
          'dbms.security.auth_enabled' => value)
      end

      def config_port!(port)
        puts "Config ports #{port} (HTTP) / #{port - 1} (HTTPS) / #{port - 2} (Bolt)"

        if server_version_greater_than_or_equal_to?('3.1.0')
          # These are not ideal, perhaps...
          modify_config_file('dbms.connector.https.enabled' => false,
                             'dbms.connector.http.enabled' => true,
                             'dbms.connector.http.listen_address' => "localhost:#{port}",
                             'dbms.connector.https.listen_address' => "localhost:#{port - 1}",
                             'dbms.connector.bolt.listen_address' => "localhost:#{port - 2}")
        elsif server_version_greater_than_or_equal_to?('3.0.0')
          modify_config_file('dbms.connector.https.enabled' => false,
                             'dbms.connector.http.enabled' => true,
                             'dbms.connector.http.address' => "localhost:#{port}",
                             'dbms.connector.https.address' => "localhost:#{port - 1}",
                             'dbms.connector.bolt.address' => "localhost:#{port - 2}")
        else
          modify_config_file('org.neo4j.server.webserver.https.enabled' => false,
                             'org.neo4j.server.webserver.port' => port,
                             'org.neo4j.server.webserver.https.port' => port - 1)
        end
      end

      # END MAIN COMMANDS

      def modify_config_file(properties)
        contents = File.read(property_configuration_path)

        File.open(property_configuration_path, 'w') { |file| file << modify_config_contents(contents, properties) }
      end

      def get_config_property(property)
        lines = File.read(property_configuration_path).lines
        config_lines = lines.grep(/^\s*[^#]/).map(&:strip).reject(&:empty?)

        lines.find do |line|
          line.match(/\s*#{property}=/)
        end.split('=')[1]
      end

      def modify_config_contents(contents, properties)
        properties.inject(contents) do |r, (property, value)|
          r.gsub(/^\s*(#\s*)?#{property}\s*=\s*(.+)/, "#{property}=#{value}")
        end
      end

      def self.class_for_os
        OS::Underlying.windows? ? WindowsServerManager : StarnixServerManager
      end

      def self.new_for_os(path)
        class_for_os.new(path)
      end

      def print_indexes
        print_indexes_or_constraints(:index)
      end

      def print_constraints
        print_indexes_or_constraints(:constraint)
      end

      protected

      def print_indexes_or_constraints(type)
        url = File.join(server_url, "db/data/schema/#{type}")
        data = JSON.load(open(url).read).map(&OpenStruct.method(:new))
        if data.empty?
          puts "No #{type.to_s.pluralize} found"
          return
        end
        criteria = lambda { |i| i.label || i.relationshipType }
        data.sort_by(&criteria).chunk(&criteria).each do |label_or_type, rows|
          puts "\e[36m#{label_or_type}\e[0m"
          rows.each do |row|
            puts "  #{row.type + ': ' if row.type}#{row.property_keys.join(', ')}"
          end
        end
      end

      def start_argument(wait)
        wait ? 'start' : 'start-no-wait'
      end

      def binary_command_path(binary_file)
        @path.join('bin', binary_file)
      end

      def neo4j_binary_path
        binary_command_path(neo4j_binary_filename)
      end

      def neo4j_command_path(command)
        neo4j_binary_path.to_s + " #{command}"
      end

      def neo4j_shell_binary_path
        binary_command_path(neo4j_shell_binary_filename)
      end

      def server_url
        if server_version_greater_than_or_equal_to?('3.1.0')
          get_config_property('dbms.connector.http.listen_address').strip.tap do |address|
            address.prepend('http://') unless address.match(/^http:\/\//)
          end
        elsif server_version_greater_than_or_equal_to?('3.0.0')
          get_config_property('dbms.connector.http.address').strip.tap do |address|
            address.prepend('http://') unless address.match(/^http:\/\//)
          end
        else
          port = get_config_property('org.neo4j.server.webserver.port')
          "http://localhost:#{port}"
        end.strip
      end

      def property_configuration_path
        if server_version_greater_than_or_equal_to?('3.0.0')
          @path.join('conf', 'neo4j.conf')
        else
          @path.join('conf', 'neo4j-server.properties')
        end
      end

      def validate_is_system_admin!
        nil
      end

      def system_or_fail(command)
        system(command.to_s) ||
          fail("Unable to run: #{command}")
      end

      def version_from_edition(edition_string)
        edition_string.downcase.gsub(/-([a-z\-]+)$/) do
          v = $1
          puts "Retrieving #{v} version..."

          version = neo4j_versions[v]

          fail "Invalid version identifier: #{v}" if !neo4j_versions.key?(v)
          fail "There is not currently a version for #{v}" if version.nil?

          puts "#{v.capitalize} version is: #{version}"

          "-#{version}"
        end.gsub(/-[a-z\-\.0-9]+$/i, &:upcase)
      end

      def pid_path
        if server_version_greater_than_or_equal_to?('3.0.0')
          @path.join('run/neo4j.pid')
        else
          @path.join('data/neo4j-service.pid')
        end
      end

      private

      NEO4J_VERSIONS_URL = 'https://raw.githubusercontent.com/neo4jrb/neo4j-rake_tasks/master/neo4j_versions.yml'

      def server_version_greater_than_or_equal_to?(version)
        Gem::Version.new(server_version) >= Gem::Version.new(version)
      end

      def server_version
        kernel_jar_path = Dir.glob(@path.join('lib/neo4j-kernel-*.jar'))[0]
        kernel_jar_path.match(/neo4j-kernel[\-a-zA-Z]*-([\-a-zA-Z\d\.]+)\.jar$/)[1]
      end

      def neo4j_versions
        require 'open-uri'
        require 'yaml'

        YAML.load(open(NEO4J_VERSIONS_URL).read)
      end

      def download_neo4j(version)
        tempfile = Tempfile.open('neo4j-download', encoding: 'ASCII-8BIT')
        url = download_url(version)

        download = Download.new(url)
        raise "#{version} is not available to download" unless download.exists?

        tempfile << download.fetch("Fetching neo4j-#{version}")
        tempfile.flush
        tempfile.path
      ensure
        puts
      end

      # POSTs to an endpoint with the form required to change a Neo4j password
      # @param [String] address
      #                 The server address, with protocol and port,
      #                 against which the form should be POSTed
      # @param [String] old_password
      #                 The existing password for the "neo4j" user account
      # @param [String] new_password
      #                 The new password you want to use. Shocking, isn't it?
      # @return [Hash]  The response from the server indicating success/failure.
      def self.change_password_request(address, old_password, new_password)
        uri = URI.parse("#{address}/user/neo4j/password")
        response = Net::HTTP.post_form(uri,
                                       'password' => old_password,
                                       'new_password' => new_password)
        JSON.parse(response.body)
      end

      def self.prompt_for(prompt, default = false)
        puts prompt
        print "#{default ? '[' + default.to_s + ']' : ''} > "
        result = STDIN.gets.chomp
        result = result.blank? ? default : result
        result
      end

      def prompt_for_address_and_passwords!
        address = prompt_for(
          'Enter IP address / host name without protocal and port',
          'http://localhost:7474')

        old_password = prompt_for(
          'Input current password. Leave blank for a fresh installation',
          'neo4j')

        new_password = prompt_for 'Input new password.'
        fail 'A new password is required' if new_password == false

        [address, old_password, new_password]
      end
    end
  end
end

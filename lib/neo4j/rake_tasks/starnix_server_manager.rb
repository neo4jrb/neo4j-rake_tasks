require File.expand_path('../server_manager', __FILE__)

module Neo4j
  module RakeTasks
    # Represents and manages a server on *NIX systems
    class StarnixServerManager < ServerManager
      def neo4j_binary_filename
        'neo4j'
      end

      def neo4j_shell_binary_filename
        'neo4j-shell'
      end

      protected

      def extract!(zip_path)
        Dir.mktmpdir do |temp_dir_path|
          system_or_fail("cd #{temp_dir_path} && tar -xvf #{zip_path}")
          subdir = Dir.glob(File.join(temp_dir_path, '*'))[0]
          system_or_fail("mv #{File.join(subdir, '*')} #{@path}/")
        end
      end

      def download_url(version)
        ENV.fetch('NEO4J_DIST', 'http://dist.neo4j.org/neo4j-VERSION-unix.tar.gz').gsub('VERSION', version)
      end
    end
  end
end

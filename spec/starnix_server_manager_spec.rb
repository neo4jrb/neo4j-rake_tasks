require 'spec_helper'
require 'pathname'
require 'fileutils'
require 'neo4j-core'

require 'neo4j/rake_tasks/starnix_server_manager'

BASE_PATHNAME = Pathname.new(File.expand_path('../', __FILE__))

module Neo4j
  module RakeTasks
    describe StarnixServerManager, vcr: true do
      let(:path) { BASE_PATHNAME.join('tmp', 'db') }
      let(:pidfile_path) { path.join('data', 'neo4j-service.pid') }

      before(:each) do
        if path.exist?
          message = 'DB temporary directory already exists! '
          message += "Delete #{path} if safe to do so and then proceed"

          fail message
        end
      end

      after(:each) do
        pid_path = path.join('data', 'neo4j-service.pid')
        if pid_path.exist?
          pid = pid_path.read.to_i
          Process.kill('TERM', pid)
          begin
            sleep(1) while Process.kill(0, pid)
          rescue Errno::ESRCH
            nil
          end
        end
        path.rmtree
      end

      let(:server_manager) { StarnixServerManager.new(path) }

      let(:neo4j_port) { 7474 }

      def open_session(port)
        Neo4j::Session.open(:server_db, "http://localhost:#{port}")
      end

      let(:neo4j_session) { open_session(neo4j_port) }

      def install(server_manager, edition = 'community-latest')
        tempfile = Tempfile.new("neo4j-#{edition}")

        neo4j_archive = 'spec/files/neo4j-community-2.2.3-unix.tar.gz'
        FileUtils.cp(neo4j_archive, tempfile.path)

        expect(server_manager)
          .to receive(:download_neo4j).and_return(tempfile.path)
        expect(server_manager)
          .to receive(:version_from_edition).and_return('community-2.2.3')

        # VCR.use_cassette('neo4j-install') do
        server_manager.install(edition)
        # end
      end

      describe '#install' do
        it 'should install' do
          install(server_manager)
        end
      end

      describe '#start' do
        before(:each) do
          install(server_manager)
        end

        it 'should start' do
          expect(pidfile_path).not_to exist

          server_manager.start

          expect(pidfile_path).to exist

          pid = pidfile_path.read.to_i
          expect(Process.kill(0, pid)).to be 1
        end
      end

      describe '#stop' do
        before(:each) do
          install(server_manager)

          server_manager.start
        end

        it 'should stop a started instance' do
          expect(pidfile_path).to exist
          pid = pidfile_path.read.to_i
          expect(Process.kill(0, pid)).to be 1

          server_manager.stop

          expect(pidfile_path).not_to exist
          expect { Process.kill(0, pid) }.to raise_error Errno::ESRCH
        end
      end

      describe '#reset' do
        before(:each) do
          install(server_manager)
          server_manager.config_auth_enabeled!(false)

          server_manager.start
        end

        it 'should wipe out the data' do
          neo4j_session.query("CREATE (:User {name: 'Bob'})")

          expect(neo4j_session.query(u: :User).count).to be 1

          server_manager.reset

          expect(neo4j_session.query(u: :User).count).to be 0
        end
      end

      describe '#config' do
        before(:each) do
          install(server_manager)

          server_manager.config_auth_enabeled!(false)
          server_manager.config_port!(port)

          server_manager.start
        end

        context 'port 7470' do
          let(:port) { 7470 }

          it 'should configure the port' do
            expect { open_session(7474) }
              .to raise_error Faraday::ConnectionFailed

            expect { open_session(port) }.not_to raise_error
          end
        end
      end
    end
  end
end

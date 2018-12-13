require 'spec_helper'
require 'pathname'
require 'fileutils'
require 'neo4j-core'
require 'open-uri'

require 'neo4j/rake_tasks/starnix_server_manager'

BASE_PATHNAME = Pathname.new(File.expand_path(__dir__))

module Neo4j
  module RakeTasks
    describe StarnixServerManager, vcr: true do
      let(:path) { BASE_PATHNAME.join('tmp', 'db') }

      let(:server_manager) { StarnixServerManager.new(path) }

      describe '#modify_config_contents' do
        subject { server_manager.modify_config_contents(contents, properties) }
        after(:each) { path.rmtree }

        let_context properties: { prop: 2 } do
          let_context(contents: 'prop=1') { it { should eq('prop=2') } }
          let_context(contents: 'prop =1') { it { should eq('prop=2') } }
          let_context(contents: 'prop= 1') { it { should eq('prop=2') } }
          let_context(contents: 'prop = 1') { it { should eq('prop=2') } }

          let_context(contents: " prop = 1 \n") { it { should eq("prop=2\n") } }

          let_context(contents: "foo=5\n prop = 1 \nbar=6") { it { should eq("foo=5\nprop=2\nbar=6") } }

          let_context(contents: '#prop=1') { it { should eq('prop=2') } }
          let_context(contents: ' #prop=1') { it { should eq('prop=2') } }
          let_context(contents: '# prop=1') { it { should eq('prop=2') } }
          let_context(contents: ' # prop=1') { it { should eq('prop=2') } }
          let_context(contents: "foo=5\n # prop=1\nbar=6") { it { should eq("foo=5\nprop=2\nbar=6") } }
        end

        let_context contents: 'prop=false' do
          let_context(properties: { prop: true }) { it { should eq('prop=true') } }
        end

        let_context contents: 'prop=true' do
          let_context(properties: { prop: false }) { it { should eq('prop=false') } }
        end
      end

      describe 'server commands' do
        let(:pidfile_path) { path.join('data', 'neo4j-service.pid') }

        def server_up(port)
          open("http://localhost:#{port}/browser/")
          true
        rescue Errno::ECONNREFUSED
          false
        end

        before(:each) do
          if server_up(neo4j_port)
            raise "There is a server already running on port #{neo4j_port}.  Can't run spec"
          end

          if path.exist?
            message = 'DB temporary directory already exists! '
            message += "Delete #{path} if safe to do so and then proceed"

            raise message
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

            server_manager.stop
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
            open_session(neo4j_port).query("CREATE (:User {name: 'Bob'})")

            expect do
              server_manager.reset
            end.to change { open_session(neo4j_port).query('MATCH (u:User) RETURN count(u) AS count').first.count }.from(1).to(0)

            server_manager.stop
          end
        end

        describe '#config' do
          before(:each) do
            install(server_manager)

            server_manager.config_auth_enabeled!(false)
            server_manager.config_port!(neo4j_port)

            server_manager.start
          end

          context 'port 7470' do
            let(:neo4j_port) { 7470 }

            it 'should configure the port' do
              expect { open_session(7474) }
                .to raise_error Faraday::ConnectionFailed

              expect { open_session(neo4j_port) }.not_to raise_error

              server_manager.stop
            end
          end
        end

        describe '#download_url' do
          it 'should return default neo4j download url' do
            ENV['NEO4J_DIST'] = nil
            expect(server_manager.send(:download_url, 'community-9.9.9'))
              .to eq('http://dist.neo4j.org/neo4j-community-9.9.9-unix.tar.gz')
          end

          it 'should return custom neo4j download url' do
            ENV['NEO4J_DIST'] = 'file://custom-location/neo4j-VERSION-unix.tar.gz'
            expect(server_manager.send(:download_url, 'community-9.9.9'))
              .to eq('file://custom-location/neo4j-community-9.9.9-unix.tar.gz')
            ENV['NEO4J_DIST'] = nil
          end
        end
      end
    end
  end
end

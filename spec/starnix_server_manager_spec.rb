require 'spec_helper'
require 'pathname'
require 'fileutils'

require 'neo4j/rake_tasks/starnix_server_manager'

BASE_PATHNAME = Pathname.new(File.expand_path('../', __FILE__))

module Neo4j
  module RakeTasks
    describe StarnixServerManager do
      let(:path) { BASE_PATHNAME.join('tmp', 'db') }

      before(:each) do
        if path.exist?
          puts "DB temporary directory already exists!"
          puts "Delete #{path} if safe to do so and then proceed"

          fail
        end
      end

      after(:each) do
        path.rmtree
      end

      it 'should install' do
        server_manager = StarnixServerManager.new(path)
        expect(server_manager).to receive(:download_url).and_return(oeuoeu)
        server_manager.install('community-latest')
      end
    end
  end
end

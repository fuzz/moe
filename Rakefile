require "aws-sdk-core"
require "bundler/setup"
require "rspec/core/rake_task"

Aws.config = {
    access_key_id: "xxx",
    secret_access_key: "xxx",
    dynamodb:  {
                  api_version: "2012-08-10",
                  endpoint: "http://localhost:4567"
                },
    region: "us-east-1"
  }

desc "Start fake_dynamo, run tests, cleanup"
task :spec do |t|
  require "tmpdir"
  require "socket"

  dir = Dir.mktmpdir
  data_file = File.join(dir, "data.fdb")

  # Launch fake_dynamo
  pid = Process.spawn"fake_dynamo", "-d", data_file, err: "/dev/null", out: "/dev/null"

  # Cleanup
  at_exit {
    Process.kill("TERM", pid)
    FileUtils.rmtree(dir)
  }

  # Wait for fake_dynamo to start taking requests
  40.downto(0) do |count| #Wait up to 2 seconds
    begin
      s = TCPSocket.new "localhost", 4567
      s.close
      break
    rescue Errno::ECONNREFUSED
      raise if(count == 0)
      sleep 0.1
    end
  end

  # Clean out old data
  Rake::Task["dbdrop"].invoke

  # Run specs
  Rake::Task["rspec"].invoke
end

spec_tasks = Dir["spec/*/"].map { |d| File.basename(d) }

spec_tasks.each do |folder|
  RSpec::Core::RakeTask.new("spec:#{folder}") do |t|
    t.pattern = "./spec/#{folder}/**/*_spec.rb"
    t.rspec_opts = %w(-fs --color)
  end
end

desc "Drop fake_dynamo"
task :dbdrop do
  sh "curl -X DELETE http://localhost:4567"
end

desc "Run specs"
task rspec: spec_tasks.map { |f| "spec:#{f}" }

desc "Default task"
task :default => [:spec]

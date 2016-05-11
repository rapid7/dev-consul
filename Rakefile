require_relative './lib/dev/consul/build'

## On interupt, wait fot the Consul process to shutdown
Signal.trap('INT') do
  Dev::Consul.stop
end

task :fetch do
  Dev::Consul::Build.fetch
end

task :run do
  Dev::Consul.run
end

task :wait do
  Dev::Consul.wait
end

task :default => [:run, :wait]

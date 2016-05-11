require_relative './consul/version'

require 'net/http'

module Dev
  ##
  # Helpers to fetch and run a development-instance of consul
  ##
  module Consul
    class << self
      def bindir
        File.expand_path('../../bin', __dir__)
      end

      def architecture
        case RUBY_PLATFORM
        when /x86_64/ then 'amd64'
        when /amd64/ then 'amd64'
        when /386/ then '386'
        when /arm/ then 'arm'
        else raise NameError, "Unable to detect system architecture for #{RUBY_PLATFORM}"
        end
      end

      def platform
        case RUBY_PLATFORM
        when /darwin/ then 'darwin'
        when /freebsd/ then 'freebsd'
        when /linux/ then 'linux'
        when /solaris/ then 'solaris'
        else raise NameError, "Unable to detect system platfrom for #{RUBY_PLATFORM}"
        end
      end

      def bin
        File.join(bindir, "consul_#{VERSION}_#{platform}_#{architecture}")
      end

      def output(arg = nil)
        @thread[:output] = arg unless @thread.nil? || arg.nil?
        @thread[:output] unless @thread.nil?
      end

      def run
        puts "Starting #{bin}"

        ## Fork a child process for Consul from a thread
        @thread = Thread.new do
          IO.popen("#{bin} agent -dev -advertise=127.0.0.1", 'r+') do |io|
            Thread.current[:process] = io.pid
            puts "Started #{bin} (#{io.pid})"

            ## Stream output
            loop do
              break if io.eof?
              chunk = io.readpartial(1024)

              if Thread.current[:output]
                Thread.current[:output].write(chunk)
                Thread.current[:output].flush
              end
            end
          end
        end

        @thread[:output] = $stdout

        ## Wait for the service to become ready
        loop do
          begin
            leader = Net::HTTP.get('localhost', '/v1/status/leader', 8500)

            if leader == '""'
              puts 'Waiting for Consul HTTP API to be ready'
              sleep 1
            end

            puts 'Consul HTTP API is ready!'
            break

          rescue Errno::ECONNREFUSED
            puts 'Waiting for Consul HTTP API to be ready'
            sleep 1
          end
        end
      end

      def wait
        @thread.join unless @thread.nil?
      end

      def stop
        unless @thread.nil?
          unless @thread[:process].nil?
            puts "Stop #{bin} (#{@thread[:process]})"
            Process.kill('INT', @thread[:process])
          end

          @thread.join
        end

        @thread = nil
      end
    end
  end
end

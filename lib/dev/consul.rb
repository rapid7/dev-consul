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

      attr_reader :output

      ## Logging helper
      def log(*message)
        return unless output.is_a?(IO)

        output.write(message.join(' ') + "\n")
        output.flush
      end

      def run(**options)
        @output = options.fetch(:output, $stdout)
        log "Starting #{bin}"


        ## Fork a child process for Consul from a thread
        @stopped = false
        @thread = Thread.new do
          IO.popen("#{bin} agent -dev -advertise=127.0.0.1", 'r+') do |io|
            Thread.current[:process] = io.pid
            log "Started #{bin} (#{io.pid})"

            ## Stream output
            loop do
              break if io.eof?
              chunk = io.readpartial(1024)

              next unless output.is_a?(IO)
              output.write(chunk)
              output.flush
            end
          end
        end

        self
      end

      def wait
        ## Wait for the service to become ready
        loop do
          break if @stopped || @thread.nil? || !@thread.alive?

          leader =
            begin
              Net::HTTP.get('localhost', '/v1/status/leader', 8500)
            rescue Errno::ECONNREFUSED
              log 'Waiting for Consul HTTP API to be ready'
              sleep 1
              next
            end

          if leader == '""'
            log 'Waiting for RAFT to initialize'
            sleep 1
            next
          end

          log 'Consul HTTP API is ready!'
          break
        end
      end

      def block
        @thread.join unless @thread.nil?
      end

      def stop
        unless @thread.nil?
          unless @thread[:process].nil?
            log "Stop #{bin} (#{@thread[:process]})"
            Process.kill('TERM', @thread[:process])
          end

          @thread.join
        end

        @thread = nil
        @stopped = true
      end
    end
  end
end

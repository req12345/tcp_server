require 'socket'

module Server
  class RequestHandler
    attr_reader :connection

    def initialize(connection)
      @connection = connection
    end

    def handle(data)
      "Request info: #{data}"
    end
  end

  class Preforking
    CRLF = "\r\n"
    CONCURRENCY = 4

    def initialize(port = 21)
      @server = Socket.new(:INET, :STREAM)
      @server.bind(Socket.pack_sockaddr_in(port, '0.0.0.0'))
      @server.listen(128)
      trap(:INT) { exit }
    end

    def gets
      @client.gets(CRLF)
    end

    def respond(message)
      @client.write(message)
      @client.write(CRLF)
    end

    def run
      child_pids = []

      CONCURRENCY.times do
        child_pids << spawn_child
      end

      trap(:INT) { 
        child_pids.each do |cpid|
          begin
            Process.kill(:INT, cpid)
          rescue Errno::ESRCH
          end
        end

        exit
      }

      loop do
        pid = Process.wait
        $stderr.puts "Process #{pid} quit unexpectedly"

        child_pids.delete(pid)
        child_pids << spawn_child
      end
    end

    def spawn_child
      fork do
        loop do
          @client, _ = @server.accept
          respond "Request accepted"            
          
          handler = Server::RequestHandler.new(@client)

          loop do         
            request = gets
            
            if request
              respond handler.handle(request)
            else
              @client.close
              break
            end
          end
        end
      end
    end
  end
end

server = Server::Preforking.new(4482)
server.run

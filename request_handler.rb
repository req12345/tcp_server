
  class RequestHandler
    CRLF = "\r\n"

    attr_reader :connection
    def initialize(connection)
      @connection = connection
    end



    def handle(data)
      IO.inspect(data)
      cmd = data[0..3].strip.upcase
      options = data[4..-1].strip


    end
  end


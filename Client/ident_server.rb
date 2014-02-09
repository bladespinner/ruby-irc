require 'socket'
require 'thread'

class IdentServer
  def initialize
    @thread = Thread.new do
      a = TCPServer.new('', 113)

      loop {
        connection = a.accept
        received = connection.recv(1024)
        connection.write received + " : USERID : UNIX : fakeid\r\n"
        connection.close
      }
    end
  end
  def start
    @thread.run
  end

  def stop
    @thread.kill
  end
end
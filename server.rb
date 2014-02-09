require './Client/credentials'
require './Client/connection'
require './Client/message'
require './Client/credentials'
 

#addr = gs.addr
#addr.shift
#puts "server is on #{addr.join(':')}"
 
#while true
#  Thread.start(gs.accept) do |s|
#    puts "#{s} is accepted"
#    while a = s.gets
#      s.write(a)
#    end
#    puts "#{s} is gone"
#    s.close
#  end
#end
class ServerConnection
  attr_accessor :recieved, :to_be_send
  def initialize(server)
    @identity = nil
    @server = server
    @recieved = []
    @to_be_send = []
    thread = Thread.start(@server.accept) do |socket|
      loop do
        while raw_message = socket.gets do
          @recieved << IRC::Message.from_raw raw_message
        end
        while to_send = @to_be_send.shift do
          socket.puts to_send
        end
      end
    end
  end

  def get_recieved_message
    @recieved.shift
  end

  def add_to_be_send_message(message)
    @to_be_send << message
  end
end

class ChannelMode
  def initialize
  end
end

ACCEPTABLE_CHANNEL_MODES = "aimnqpsrtlk"
ACCEPTABLE_USER_MODES = "Oov"

class Channel
  attr_accessor :name, members, modes
end

class IRCServer
  def initiate
    @connections = []
    @message_distributor = MessageDistributor.new
  end

  def run
    @server = TCPServer.open(0)
    @running = true;
    await_connections
  end

  def clear_dead_connections
    @connections = @connections.select do |thread|
      thread.alive?
    end
  end

  def distribute_connection_messages
    @connection
  end

  def distribute_messages
    @connections.each do |connection|
      distribute_connection_messages connection
    end
  end

  def await_connections
    while @running
      connection = ServerConnection.new server,message_distributor
      @connections << connection
    end
  end

  def manage_connection
    puts "#{s} is accepted"
    while a = s.gets
      s.write(a)
    end
    puts "#{s} is gone"
    s.close
  end
end

#IRCServer.new.run
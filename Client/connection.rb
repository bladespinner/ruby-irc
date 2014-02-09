require 'socket'
require 'thread'
require_relative './constants'
require_relative './server_details'
require_relative './credentials'
require_relative './commands'
require_relative './message'
require_relative './ident_server'

include IRC
include IRC::Commands

module IRC
  class Connection
    attr_reader :server_details, :identity, :socket, :recieved
    def initialize(server_details,identity)
      @server_details = server_details
      @identity = identity
      @recieved = Array.new
      #@ident_server = IdentServer.new
    end

    def open
      #@ident_server.start
      @socket = TCPSocket.open @server_details.server, @server_details.port
      if @identity.password then
        msg = Message.new (password @identity.password) , nil
        @socket.puts msg.to_s
      end

      msg = Message.new (user @identity.user_name, @identity.mode, @identity.real_name) , nil
      @socket.puts msg.to_s

      msg = Message.new (nickname @identity.nickname) , nil
      @socket.puts msg.to_s

      @thread = Thread.new do
        loop do
          recieve
        end
      end
    end

    def close(message = "quit")
      @thread.kill
      @socket.puts quit message
      @socket.close
      #@ident_server.stop
    end

    def execute(command)
      send Message.new command , nil
    end

    def send(message)
      @socket.puts message.to_s, 0
    end

    def recieve
      reading, data, buffer = 0, "", nil
      while reading != 2
        buffer = @socket.read 1
        if buffer == Constants::CARRAGE_RETURN_CHARACTER then
          reading = 1
        elsif buffer == Constants::LINE_FEED_CHARACTER and reading == 1 then
          reading = 2
        else
          reading = 0
          data += buffer
        end
      end
      @recieved << (Message.from_raw data)
    end
  end
end

#identity = Identity.new "Rubyisgood", 0, "testing", "Testing",nil
#server = ServerDetails.new "irc.rizon.net", 6667
#connection = Connection.new server, identity
#connection.open
#loop do
#  a = gets.chomp
#  puts a
#end
#connection.close

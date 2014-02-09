require './Client/credentials'
require './Client/connection'
require './Client/message'
require './Client/credentials'
require './Client/prefix'
require 'yaml/store'

module NumericCommands
  ERR_ALREADYREGISTRED = "462"
end

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
    @last_recieve_time = Time.now
    @connection_thread = Thread.start(@server.accept) do |socket|
      @socket = socket

      read_messages socket
      server.clear_dead_connections
    end
  end

  def get_recieved_message
    @recieved.shift
  end

  def add_to_be_send_message(message)
    @socket.puts message.to_s
  end

  def close
    @socket.close
    @connection_thread.kill
    
  end

  def read_messages(socket)
    loop do
        raw_message = socket.gets
        if raw_message do
          @last_recieve_time = Time.now
          @ping_send = false
          time = Time.now
          message = IRC::Message.from_raw raw_message
          server.message_perpetrator.process_request self, message
        end
      end
    end
  end

  def is_alive?
    @ping_send = false
    if ((Time.now - @last_recieve_time).min >= 1) and !ping_send then
      socket.puts Message.new nil, (Command.new "PING" server.prefix.name)
      @ping_send = true
      true
    elsif ((Time.now - @last_recieve_time).min >= 2) then
      false
    else
      true
    end
  end
end

class PassHandler
  def command
    "PASS"
  end

  def process(request)
    if request.source_connection.identity != null then
      command = Command.new NumericCommands::ERR_ALREADYREGISTRED , "Unauthorized command (already registered)"
      message = Message.new request.server_prefix, command
      connection.add_to_be_send_message message
    end
  end
end

class MessagePerpetrator
  def initialize
    @handlers = []
  end

  def find_handler(message)
    @handlers.find do |handler|
      message.command.command_name == handler.command
    end
  end

  def perpetrate_message(request)
    handler = find_handler request.message
    if handler then
      handler.process request
    end
  end
end

ACCEPTABLE_CHANNEL_MODES = "aimnqpsrtlk"
ACCEPTABLE_USER_MODES = "Oov"

class Channel
  attr_accessor :name, :members, :modes
end

class User
  attr_accessor :id, :user_name, :nickname, :password_hash
end

class NickHistoryRecord
  attr_accessor :id, :nickname, :time, :user_id
end

class Request
  attr_accessor :server_prefix, :store, :connections, :message, :source_connection
  initialize(server_prefix,store,connections,source_connection)
    @server_prefix = server_prefix
    @store = store
    @connections = connections
    @source_connection = source_connection
  end
end

class ServerData
  def initialize(location,server_prefix)
    @server_prefix
    @store = YAML::Store.new location
  end

  def save_state
    @store.transaction do
      @store["users"] = @users
      @store["channels"] = @channels
      @store["nickname_history"] = @nickname_history
    end
  end

  def load_state
    @store.transaction do
      @users = @store["users"]
      @channels = @store["channels"]
      @nickname_history = @store["nickname_history"]
    end
  end

  def add_user_to_store(user)
    @store.transaction do
      users << user
      store["users"] << user
    end
  end

  def add_channel_to_store(user)
    @store.transaction do
      users << user
      store["users"] << user
    end
  end

  def add_nickname_to_history(nickname)
    @store.transaction do
      user = @users.find do |user|
        user.nickname == nickname
      end
      if user then
        record = NickHistoryRecord.new 10, nickname, Time.now, user.id
        nickname_history << record
        @store["nickname_history"] << record
      end
    end
  end

  attr_accessor :channels,:users,:nickname_history
end

class IRCServer
  attr_reader :message_perpetrator,:prefix
  def initialize(name)
    @prefix = Prefix.new name
    @connections = []
    @message_perpetrator = MessagePerpetrator.new
    @data_store = ServerData.new
  end

  def run
    @server = TCPServer.open(0)
    @running = true;
    await_connections
  end

  def clear_dead_connections
    @live_tracker = Thread.new do
      @connections = @connections.select do |connection|
        if !@connection.is_alive? then
          connection.kill
          false
        else
          true
        end
      end
    end
    @live_tracker.run
  end

  def process_request(connection,message)
    request = Request.new @prefix, @data_store, @connections, message, connection
    @message_perpetrator.perpetrate_message request
  end

  def await_connections
    while @running
      connection = ServerConnection.new server
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
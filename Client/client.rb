require './connection'
require './server_details'
require './credentials'
require './command'
module IRC
  module Client
    class IRCClient
      attr_accessor :current_reciever

      def initialize()
        @commands = [Send,Reciever,Join,Quit,Part,Nick,Raw]
        @message_handlers = [NicknameTaken,BadNickname,Ping,Info,Message]
      end

      def welcome
        puts "Welcome to ruby-irc";
        puts "write /help for avaliable commands"
      end

      def get_server_details
        puts "Server:Port :"
        server = gets.chomp
        parts = server.split ':'
        if parts.length == 2 then
          IRC::ServerDetails.new parts[0],parts[1]
        else
          IRC::ServerDetails.new parts[0]
        end
      end

      def get_client_mode
        puts "Mode : "
        mode_raw , mode = gets.chomp , 0
        if mode_raw.include? "i" then mode += 8 end
        if mode_raw.include? "w" then mode += 4 end
        mode
      end

      def get_client_info
        puts "Username : "
        username = gets.chomp
        puts "Real Name : "
        real_name = gets.chomp
        puts "Nickname : "
        nickname = gets.chomp
        mode = get_client_mode
        puts "Setup a password ? [Y/N] :"
        has_password = gets.chomp
        if has_password.downcase == 'y'
          puts "Password : "
          password = gets.password
          IRC::Identity.new nickname, mode, username, real_name, password
        else
          IRC::Identity.new nickname, mode, username, real_name, nil
        end
      end

      def get_connection
        welcome
        server_details = get_server_details
        identity = get_client_info
        @connection = Connection.new server_details, identity
      end

      def run
        get_connection
        @connection.open
        @message_processing_thread = Thread.new do
          loop do
            handle_next_message
          end
        end
        @message_processing_thread.run
        @running = true
        read_user_input
      end

      def read_user_input
        while @running
          user_input = gets.chomp
          process_user_command user_input
        end
      end

      def process_user_command(user_command)
        if user_command[0,1] == '/' then
          raw_command = user_command.split
          command = raw_command[0][1..-1]
          parameters = raw_command.drop(1)
          command_processor = find_command_processor command
          if command_processor then
            command_processor.action self,parameters
          else
            if @current_reciever then
              Send.action parameters
            end
          end
        end
      end

      def find_command_processor(command)
        @commands.find do |command_processor|
          command_processor.command == command
        end
      end

      def stop
        @connection.close
        @message_processing_thread.kill
        @running = false
      end

      def find_message_handler(command_name)
        @message_handlers.find do |processor|
          processor.command.include? command_name
        end
      end

      def handle_next_message
        message = @connection.recieved.shift
        if message then
          puts message.to_s
        # handle_message(message)
        end
      end

      def handle_message(message)
        handler = find_message_handler message.command.command_name
        if handler then
          if (!handler.suppress_output) then
            puts "<" + message.prefix.to_s + ">" + message.command.parameters.join(' ')
          end
          handler.action(@connection, message)
        else
          puts "<" + message.prefix.to_s + ">" + message.command.parameters.join(' ')
        end
      end

      def execute(irc_command)
        @connection.execute(irc_command)
      end
    end

    #client commands
    class Raw
      def self.command
        "raw"
      end

      def self.action(client,*parameters)
        command = IRC::Command.new *parameters
        client.execute command
      end
    end
    class Send
      def self.command
        "send"
      end

      def self.action(client,*parameters)
        if parameters[0] == "-to" then
          command = IRC::Commands::message parameters[0], parameters.drop(1).join(' ')
          client.execute command
        else
          client.execute IRC::Commands::message client.current_reciever, parameters.join(' ')
        end
      end
    end

    class Reciever
      def self.command
        "set-reciever"
      end

      def self.action(client,*parameters)
        client.current_reciever = parameters[0]
      end
    end

    class Join
      def self.command
        "join"
      end

      def self.action(client,*parameters)
        if parameters.length == 0 then return false end
        client.current_reciever = parameters[0]
        if parameters.length > 1 then
          client.execute IRC::Commands::join [parameters[0]], [parameters[1]]
        else
          client.execute IRC::Commands::join [parameters[0]]
        end
      end
    end

    class Quit
      def self.command
        "quit"
      end

      def self.action(client,*parameters)
        client.stop
      end
    end

    class Part
      def self.command
        "part"
      end

      def self.action(client,*parameters)
        if parameters[0] == "/all" then
          client.execute IRC::Commands::part_all
        else
          client.execute IRC::Commands::part *parameters
        end
      end
    end

    class Nick
      def self.command
        "private"
      end

      def self.action(client,*parameters)
        if parameters[0] == "/all" then
          client.execute IRC::Commands::part_all
        else
          client.execute IRC::Commands::part *parameters
        end
      end
    end

    #message handlers

    class Message
      def self.command
        ["PRIVMSG"]
      end

      def self.suppress_output
        true
      end

      def self.action(client,message)
        puts "<" + message.command.prefix.to_s + " to " + message.command.parameters[0]+">" + message.command.parameters[1]
      end
    end

    class Info
      def self.command
        ["001","002","003","004","005","251","252","254","254"] +
        ["255","265","266","250","375","372","376"]
      end

      def self.suppress_output
        true
      end

      def self.action(client,message)
        puts message.command.parameters.drop(1).join(" ")
      end
    end

    class NicknameTaken
      def self.command
        ["433"]
      end

      def self.suppress_output
        false
      end

      def self.action(client,message)
        puts "% Nickname in use , use /nick command to select another one %"
      end
    end

    class BadNickname
      def self.command
        ["432"]
      end

      def self.suppress_output
        false
      end

      def self.action(client,message)
        puts "% Bad nickname format. %"
      end
    end

    class Ping
      def self.command
        ["PING"]
      end

      def self.suppress_output
        true
      end

      def self.action(client,message)
        connection.execute IRC::Commands::pong message.command.parameters[0]
      end
    end
  end
end

client = IRC::Client::IRCClient.new
client.run
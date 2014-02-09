require_relative './command'
require_relative './prefix'

module IRC
  class Message
    attr_reader :command, :prefix

    def initialize(command, prefix = nil)
      @command = command
      @prefix = prefix
    end

    def to_s
      (@prefix ? @prefix.to_s + " " + @command.to_s : @command.to_s).squeeze " "
    end

    def self.from_raw(raw_message)
      raw_command, raw_prefix = nil, nil
      if raw_message[0] == ':' then
        prefix_end = raw_message.index ' '
        raw_prefix = raw_message[0..(prefix_end - 1)]
        raw_command = raw_message[(prefix_end + 1)..(raw_message.length - 1)]
        Message.new (Command.from_raw raw_command), (Prefix.from_raw raw_prefix)
      else
        Message.new (Command.from_raw raw_message)
      end
    end
  end
end
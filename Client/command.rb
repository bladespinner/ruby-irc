module IRC
  class Command
    attr_reader :command_name,:parameters
    def initialize(command_name,*parameters)
      @command_name = command_name
      @parameters = parameters.compact
    end

    def trailing
      if @parameters.last.include? " " then
        @parameters.last
      else
        ""
      end
    end

    def to_s
      trailing = (@parameters.last.include? " ") ? ":" + @parameters.last : @parameters.last
      command = @command_name + " " + (@parameters[0..-2].join " ") + " " + trailing
      command.strip.squeeze " "
    end

    def self.from_raw(raw_command)
      command_parts = raw_command.split ':'
      command_and_parameters = command_parts[0]
      trailing_parameter = command_parts[1]
      segments = command_parts[0].split
      command_name = segments.first
      parameters = (segments.drop 1) + [trailing_parameter]
      Command.new command_name,*parameters
    end
  end
end
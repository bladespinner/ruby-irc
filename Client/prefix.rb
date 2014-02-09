module IRC
  class Prefix
    attr_reader :name,:host,:user

    def initialize(name, host = nil , user = nil)
      @name = name
      @host = host
      @user = user
    end

    def to_s
      if name then
        return "#{name}!#{user}@#{host}" if user and host
        return "#{name}@host" if user
        "#{name}"
      end
    end

    def self.from_raw(raw_prefix)
      return Prefix.new if not raw_prefix
      prefix_parts = raw_prefix.split '/[!,@]/'
      if prefix_parts.length == 3 then 
        Prefix.new prefix_parts[0], prefix_parts[1], prefix_parts[2]
      elsif prefix_parts.length == 2 
        then Prefix.new prefix_parts[0], prefix_parts[1]
      elsif prefix_parts.length == 1 
        then Prefix.new prefix_parts[0]
      else Prefix.new end
    end
  end
end

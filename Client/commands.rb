require_relative "./command"

module IRC
  module Commands
    def password(password)
      Command.new "PASS", password
    end

    def nickname(nick)
      Command.new "NICK", nick
    end

    def user(username, mode, real_name)
      Command.new "USER", username,mode, "*" ,real_name
    end

    def operator(name, password)
      Command.new "OPER", name, password
    end

    def mode(nickname, setting)
      Command.new "MODE", nickname, setting
    end

    def service(nickname, reserved, distribution, type)
      Command.new "SERVICE", nickname, reserved, distribution, type 
    end

    def quit(message = 'quit')
      Command.new "QUIT", message
    end

    def squit(server, message = "quiting")
      raise NotImplementedError.new
    end

    def join(channels,keys = nil)
      if keys then
        Command.new "JOIN", channels.join(','), keys(',')
      else
        Command.new "JOIN", channels.join(',')
      end
    end

    def part_all
      Command.new "JOIN", "0"
    end

    def part(message, *channels)
      Command.new "PART", channels.join(','), message
    end

    def channel_mode(channel, setting)
      mode channel, setting
    end

    def topic(channel, message = nil)
      Command.new "TOPIC", channel , message
    end

    def names(target,channels)
      Command.new "NAMES", channels.join(','), target
    end

    def list(target = nil,*channels)
      Command.new "LIST", channels, target
    end

    def invite(nickname, channel)
      Command.new "INVITE", nickname, channel
    end

    def kick(channels,users,message)
      Command.new "KICK", channels, users, message
    end

    def message(target, message)
      Command.new "PRIVMSG", target, message
    end

    def notice(target, message)
      Command.new "NOTICE" ,target, message
    end
    def motd(target = nil)
      Command.new "MOTD" ,target, message
    end

    def lusers(mask = nil, target = nil)
      Command.new "LUSERS", mask, target
    end

    def version(target = nil)
      Command.new "VERSION", target
    end

    def stats(query = nil, target = nil)
      Command.new "STATS", query, target
    end

    def links(remote_server = nil, server_mask = nil)
      Command.new "LINKS", remote_server, server_mask
    end

    def time(target = nil)
      Command.new "TIME", target
    end

    def server_connect(target, port, remote = nil)
      Command.new "CONNECT", target, port, remote
    end

    def trace(target = nil)
      Command.new "TRACE", target
    end

    def admin(target = nil)
      Command.new "ADMIN", target
    end

    def info(target = nil)
      Command.new "INFO", target
    end

    def server_list(mask = nil, type = nil)
      Command.new "SERVLIST", mask , type
    end

    def squery(service, text)
      Command.new "SQUERY", service, text
    end

    def who(mask, mode = 'o')
      Command.new "WHO", mask, mode
    end

    def whois(target,*masks)
      Command.new "WHOIS", target, masks.join(',')
    end

    def whowas(count, target, *nicknames)
      Command.new "WHOWAS" , nicknames.join(','), count, target
    end

    def kill(nickname, comment = "Connection is kill")
      Command.new "KILL", nickname, comment
    end

    def ping(server, target = '')
      Command.new "PING", server, target
    end

    def pong(server, target)
      Command.new "PONG", server, target
    end

    def error(message)
      Command.new "ERROR", message
    end

    def away(message = nil)
      Command.new "AWAY", message
    end

    def rehash
      Command.new "REHASH"
    end

    def die
      Command.new "DIE"
    end

    def restart
      Command.new "RESTART"
    end

    def summon(user, target = nil, channel = nil)
      Command.new "SUMMON", use, target, channel
    end

    def users(target = nil)
      Command.new "USERS", target
    end

    def wallops(message)
      Command.new "WALLOPS", message
    end

    def userhost(*nicks)
      raise ArgumentError.new("Wrong number of arguments") unless nicks.size > 0 && nicks.size <= 5
      Command.new "USERHOST", nicks
    end

    def ison(*nicks)
      Command.new "ISON", nicks
    end
  end
end
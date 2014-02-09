class IRC::ServerDetails
  attr_reader :server,:port

  def initialize(server,port = 6667)
    @server = server
    @port = port
  end

  def to_s
    @server + ":" + @port
  end
end
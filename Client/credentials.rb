module IRC
  class Identity
    attr_accessor :nickname, :user_name, :real_name, :password, :mode, :id
    def initialize(nickname, mode=0, user_name=nil,real_name=nil, password=nil)
      @nickname = nickname
      @user_name = user_name
      @mode = mode
      @real_name = real_name
      @password = password
    end
  end
end
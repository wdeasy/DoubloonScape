module Bot
  def self.find_member_with_role
    member = nil
    begin
      server(CONFIG.server).users.each do |user|
        user.roles.each do |r|
          if role.id.to_i == CONFIG.role
            member = user
          end
        end
      end
    rescue Exception => msg
      Bot.log "Error seaching for member with role."
      puts msg
    end
    return member.id
  end

  def self.get_name(member)
    name = ''
    if member.nickname.nil?
      name = member.username
    else
      name = member.nickname
    end
    return name.strip
  end

  def self.get_user(user_id)
    user = nil
    begin
      user = BOT.user(user_id)
    rescue Exception => msg
      Bot.log "Error while trying to pull the user object."
      puts msg
    end
    return user
  end

  def self.get_member(user_id)
    user = nil
    begin
      user = BOT.server(CONFIG.server).member(user_id)
    rescue Exception => msg
      Bot.log "Error while trying to pull the member object."
      puts msg
    end
    return user
  end

  def self.set_name(user_id, name)
    begin
      user = BOT.server(CONFIG.server).member(user_id).nickname = name
    rescue Exception => msg
      Bot.log "Error while trying to set nickname."
      puts msg
    end
  end

  def self.set_game(game)
    begin
      BOT.game = game
    rescue Exception => msg
      Bot.log "Error while trying to pull the user object."
      puts msg
    end
  end

  def self.set_status(stat)
    case stat
    when 'online'
      BOT.online
    when 'idle'
      BOT.idle
    when 'dnd'
      BOT.dnd
    when 'invisible'
      BOT.invisible
    end
  end
end

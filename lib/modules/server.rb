module Bot
  def self.get_server
    server = nil
    begin
      server = BOT.server(CONFIG.server)
    rescue Exception => msg
      Bot.log "Error while trying to pull the server object."
      puts msg
    end
    return server
  end

  def self.get_server_owner
    owner = nil
    begin
      owner = BOT.server(CONFIG.server).owner
    rescue Exception => msg
      Bot.log "Error while looking up the server owner."
      puts msg
    end
    return owner
  end

  def self.get_members
    members = nil
    begin
      members = BOT.server(CONFIG.server).members
    rescue Exception => msg
      Bot.log "Error while getting server members."
      puts msg
    end
    return members
  end

  def self.get_members_status
    status = {}
    members = get_members
    members.each do |member|
      status[member.id.to_i] = member.status
    end
    return status
  end

end

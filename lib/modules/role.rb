module Bot
  def self.grant_role(member, role)
    begin
      member.add_role role
    rescue Exception => msg
      puts "Error granting Captain Role to the new captain."
      puts msg
    end
  end

  def self.revoke_role(member, role)
    begin
      member.remove_role role
    rescue Exception => msg
      puts msg
    end
  end

  def self.find_role
    role = nil
    begin
      role = BOT.server(CONFIG.server).roles.find { |r| r.id == CONFIG.role }
    rescue Exception => msg
      puts "Error while searching for the Captain Role object."
      puts msg
    end
    return role
  end

  def self.find_role_by_name(name)
    role = nil
    begin
      role = BOT.server(CONFIG.server).roles.find { |r| r.name.downcase.include? 'captain' }
    rescue Exception => msg
      puts "Error while searching for the Captain Role object by name."
      puts msg
    end
    return role
  end
end
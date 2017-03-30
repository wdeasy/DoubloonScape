module Bot
  def self.set_topic(topic)
    begin
      BOT.channel(CONFIG.channel).topic = topic
    rescue Exception => msg
      puts "Error while trying to set the channel topic."
      puts msg
    end
  end

  def self.send_chat(message)
    begin
      BOT.channel(CONFIG.channel).send_message("`#{message}`")
    rescue Exception => msg
      puts "Error while trying to send message to channel."
      puts msg
    end
  end

  def self.get_channel
    channel = nil
    begin
      channel = BOT.channel(CONFIG.channel)
    rescue Exception => msg
      puts "Error while trying to pull the channel object."
      puts msg
    end
    return channel
  end
end
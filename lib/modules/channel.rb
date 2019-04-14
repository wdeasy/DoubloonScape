module Bot
  def self.set_topic(topic)
    begin
      BOT.channel(CONFIG.channel).topic = topic
    rescue Exception => msg
      Bot.log "Error while trying to set the channel topic to:"
      Bot.log topic
      puts msg
    end
  end

  def self.send_chat(message)
    begin
      Bot.log message
      BOT.channel(CONFIG.channel).send_message("`#{message}`")
    rescue Exception => msg
      Bot.log "Error while trying to send message to channel to:"
      Bot.log message
      puts msg
    end
  end

  def self.get_channel
    channel = nil
    begin
      channel = BOT.channel(CONFIG.channel)
    rescue Exception => msg
      Bot.log "Error while trying to pull the channel object."
      puts msg
    end
    return channel
  end
end

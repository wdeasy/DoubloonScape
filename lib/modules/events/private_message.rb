module Bot
  module DiscordEvents
    module PrivateMessage
      extend Discordrb::EventContainer
      message do |event|
        Bot.log "PM: #{event.author.username} : #{event.content}"
      end
    end
  end
end

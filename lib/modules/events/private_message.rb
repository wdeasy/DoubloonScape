module Bot
  module DiscordEvents
    module PrivateMessage
      extend Discordrb::EventContainer
      private_message do |event|
        if event.channel.pm?
          Bot.log "PM: #{event.author.username}: #{event.content}"
        end
      end
    end
  end
end

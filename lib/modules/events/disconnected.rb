module Bot
  module DiscordEvents
    module Disconnected
      extend Discordrb::EventContainer
      disconnected do |event|
      	Bot.log "Bot disconnected."
        DOUBLOONSCAPE.stop
        $exit = true
      end
    end
  end
end

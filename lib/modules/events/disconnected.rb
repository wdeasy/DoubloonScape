module Bot
  module DiscordEvents
    module Disconnected
      extend Discordrb::EventContainer
      disconnected do |event|
      	puts "Bot disconnected."
        DOUBLOONSCAPE.stop
      end
    end
  end
end
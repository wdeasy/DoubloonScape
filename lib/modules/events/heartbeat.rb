module Bot
  module DiscordEvents
    module Heartbeat
      extend Discordrb::EventContainer
      heartbeat do |event|
      	DOUBLOONSCAPE.start
      end
    end
  end
end

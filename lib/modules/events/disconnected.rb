module Bot
  module DiscordEvents
    module Disconnected
      extend Discordrb::EventContainer
      disconnected do |event|
      	puts "Bot disconnected."
        DOUBLOONSCAPE.stop
        unless $game.nil?
          Thread.kill($game)
        end
      end
    end
  end
end

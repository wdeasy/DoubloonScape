module Bot
  module DiscordCommands
    module Reset
      extend Discordrb::Commands::CommandContainer
      command(:reset, help_available: false) do |event|
        Bot.log "#{event.author.username}: #{event.content}"
        break unless event.user.id == CONFIG.owner
        Bot.send_chat("The ship is goin down!")

        unless $game.nil?
          Thread.kill($game)
        end
        DOUBLOONSCAPE.stop
        Bot.remove_captains
        unless DOUBLOONSCAPE.current_captain.nil?
          Bot.set_name(DOUBLOONSCAPE.current_captain, DOUBLOONSCAPE.current_name('landlubber'))
        end
        BOT.game = nil
        BOT.stop
        sleep 5
        BOT.run
      end
    end
  end
end

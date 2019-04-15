module Bot
  module DiscordCommands
    module Exit
      extend Discordrb::Commands::CommandContainer
      command(:exit, help_available: false) do |event|
        Bot.log "#{event.author.username}: #{event.content}"
        break unless event.user.id == CONFIG.owner
        Bot.send_chat("The ship is goin down!")
        $exit = true
        DOUBLOONSCAPE.stop
        Bot.remove_captains
        unless DOUBLOONSCAPE.current_captain.nil?
          Bot.set_name(DOUBLOONSCAPE.current_captain, DOUBLOONSCAPE.current_name('landlubber'))
        end
        Bot.set_topic(nil)
        BOT.game = nil
        $game.terminate!
        exit
      end
    end
  end
end

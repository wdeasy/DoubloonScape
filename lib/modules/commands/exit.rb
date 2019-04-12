module Bot
  module DiscordCommands
    module Exit
      extend Discordrb::Commands::CommandContainer
      command(:exit, help_available: false) do |event|
        break unless event.user.id == CONFIG.owner
        Bot.send_chat("The ship is goin down!")
        DOUBLOONSCAPE.stop
        Bot.remove_captains
        unless DOUBLOONSCAPE.current_captain.nil?
          Bot.set_name(DOUBLOONSCAPE.current_captain, DOUBLOONSCAPE.current_name('landlubber'))
        end
        Bot.set_topic(nil)
        BOT.game = nil
        Thread.kill($game)
        exit
      end
    end
  end
end

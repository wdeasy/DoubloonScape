module Bot
  module DiscordEvents
    # This event is processed each time the bot succesfully connects to discord.
    module Ready
      extend Discordrb::EventContainer
      ready do |event|
        BOT.idle
        Bot.remove_captains
        DOUBLOONSCAPE.update_captains_status(Bot.get_members_status)
        Bot.reset_captain
        DOUBLOONSCAPE.start
        Bot.send_chat "Anchors Aweigh! DoubloonScape has begun!"
        Bot.log "Bot connected."
        Bot.update_topic(DOUBLOONSCAPE.status)

        if $game.nil? || !$game.alive?
          begin
            $exit = false
            $game = Thread.new {
              Bot.game_loop
            }
          rescue Exception => msg
            Bot.log "Error in the game loop."
            puts msg
          end
        else
          $exit = false
          $game.wakeup
        end

        th=0
        Threads.each do |t|
          th+=1
        end
        Bot.log "Thread count: #{th}"

      end
    end
  end
end

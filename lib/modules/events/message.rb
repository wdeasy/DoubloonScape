module Bot
  module DiscordEvents
    module Message
      extend Discordrb::EventContainer
      phrase = /\b[Ii]['’]?[Mm][ \t]+[Tt][Hh][Ee][ \t]+[Cc][Aa][Pp][Tt][Aa][Ii][Nn][ \t]+[Nn][Oo][Ww].?\b/
      message(contains: phrase) do |event|
        unless Bot.is_legit(event) == false
          if Time.now < DOUBLOONSCAPE.cooldown
            seconds = (DOUBLOONSCAPE.cooldown - Time.now).ceil
            Bot.send_chat("The Captain cannot be taken for #{seconds} more seconds.")
          else
            if DOUBLOONSCAPE.brig.key? event.author.id.to_i
              Bot.send_chat("You are currently sitting in the Brig and are incapable of being Captain.")
            else
              if DOUBLOONSCAPE.locked == false
                DOUBLOONSCAPE.lock
                game_events = DOUBLOONSCAPE.change_captains(event.author.id.to_i, Bot.get_name(event.author))
                unless game_events.empty?
                  if game_events[:contest].empty? || game_events[:contest][:success] == false
                    Bot.update_roles(event.author)
                    Bot.update_names
                    Bot.update_topic(DOUBLOONSCAPE.status)
                    BOT.game = DOUBLOONSCAPE.current_name('landlubber')
                    Bot.log "#{DOUBLOONSCAPE.current_name('landlubber')} has taken Captain."
                  end
                end
                Bot.send_events(game_events)
                DOUBLOONSCAPE.unlock
              end
            end
          end
        end
      end
    end
  end
end

module Bot
  module DiscordCommands
    module Achievements
      extend Discordrb::Commands::CommandContainer
      command(:achievements, help_available: false) do |event|
        captain = DOUBLOONSCAPE.captain(event.author.id.to_i)
        unless captain.nil?
          stats = "**Achievements [#{captain.achieves.count}]**\n"
          captain.achieves.achievements.each do |name, achieve|
            if achieve.unlocked == true
              if stats.length + "`#{achieve.display_name} - #{achieve.description}`\n".length > 1999
                event.send_message(stats.strip)
                stats = "`#{achieve.display_name} - #{achieve.description}`\n"
              else
                stats += "`#{achieve.display_name} - #{achieve.description}`\n"
              end
            end
          end

          begin 
            puts "!achievements #{captain.landlubber_name}"
            event.send_message(stats.strip)
            #event.respond stats.strip   
          rescue Exception => msg
            puts "Error while trying to display achievements."
            puts msg            
          end
        end 
      end
    end
  end
end
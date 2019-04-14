module Bot
  module DiscordCommands
    module Stats
      extend Discordrb::Commands::CommandContainer
      command(:stats, help_available: false) do |event|
        captain = DOUBLOONSCAPE.captain(event.author.id.to_i)
        unless captain.nil?
          stats = "**#{captain.landlubber_name}**\n"
          stats += "`Level:                      #{captain.level}`\n"
          stats += "`Gold:                       #{captain.gold.floor.to_i}`\n"
          stats += "`Captains Taken:             #{captain.count}`\n"
          stats += "`Longest Time as Captain:    #{Bot.minutes(captain.record)}`\n"
          stats += "`Total Minutes as Captain:   #{Bot.minutes(captain.total)}`\n"

          stats += "\n**Achievements [#{captain.achieves.count}]**\n"

          stats += "\n**Inventory [#{captain.inv.ilvl}]**\n"
          captain.inv.inventory.each do |slot, item|
            stats += "`#{slot.ljust(10)} [#{item.ilvl}]#{item.name}`\n"
          end

          begin
            Bot.log "!stats #{captain.landlubber_name}"
            event.respond stats.strip
          rescue Exception => msg
            Bot.log "Error while trying to display stats."
            puts msg
          end
        end
      end
    end
  end
end

module Bot
  module DiscordCommands
    module Leaderboard
      extend Discordrb::Commands::CommandContainer
      command(:leaderboard, help_available: false) do |event|
        Bot.log "#{event.author.username}: #{event.content}"
        leaderboard = DOUBLOONSCAPE.leaderboard
          unless leaderboard.empty?
          message = "#{"`".ljust(20)}#{"score".ljust(10)}#{"level".ljust(10)}#{"ilvl".ljust(10)}#{"gold".ljust(10)}\n"
          leaderboard.each_with_index do |(name, hash), index|
            place = "[#{index + 1}]"
            capn = name[0..14].to_s.gsub(/[^0-9a-z ]/i, '')
            placecapn = "#{place}#{capn}".ljust(20)
            score = hash[:score].to_s.ljust(10)
            level = hash[:level].to_s.ljust(10)
            ilvl = hash[:ilvl].to_s.ljust(10)
            gold = hash[:gold].floor.to_i.to_s.ljust(10)

            message += "#{placecapn}#{score}#{level}#{ilvl}#{gold}\n"
          end
          Bot.send_chat(message.strip)
        end
      end
    end
  end
end

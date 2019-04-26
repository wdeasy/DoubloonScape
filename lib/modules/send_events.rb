module Bot
  def self.achieve_event(value)
    value.each do |name, description|
      send_chat("Achievement Unlocked! #{name} - #{description}")
    end
  end

  def self.bonus_event(value)
    send_chat("First Captain of the Day Bonus!")
  end

  def self.level_event(value)
    send_chat("#{value[:name]} has hit level #{value[:level]}!")
  end

  def self.record_event(value)
    send_chat("#{value[:name]} has broken their previous record of #{minutes(value[:record])} min. spent as Captain!")
  end

  def self.event_event(value)
      place = value[:place].upcase
      unit = value[:unit] == :goldxp ? 'Gold and XP' : 'Time'
      #modifier = value[:modifier] == :buff ? 'decreased' : 'increased'
      modifier = 'increased'
      if value[:place] == 'bermuda triangle' && value[:modifier] == :buff
        modifier = 'decreased'
      end
      amount = value[:amount]
      send_chat("#{place}! #{unit} #{modifier} by #{amount}% for the next #{DoubloonScape::BUFF_DURATION} mins.")
  end

  def self.item_event(value)
    if value[:quality] == :unique
      send_chat("#{value[:captain]} found a unique item! #{value[:name]}[#{value[:ilvl]}]")
      send_chat("\"#{value[:description]}\"")
    else
      send_chat("#{value[:captain]} found a common #{value[:name]}[#{value[:ilvl]}].")
    end
  end

  def self.contest_event(value)
    case value[:event]
    when :mutiny
      mutineers = "#{value[:mutineers].join(", ")}"
      send_chat("#{mutineers} think #{value[:captain]} is unworthy of the wheel and have called for a mutiny!")
      if value[:success] == true
        send_chat("The mutineers have overthrown #{value[:captain]} and gained #{DoubloonScape::MUTINEER_BONUS}% XP!")
        send_chat("#{value[:captain]} will spend the next #{DoubloonScape::BRIG_DURATION} mins in the brig.")
      else
        send_chat("#{value[:captain]} successfully held off the mutiny and secured Captain for the next #{DoubloonScape::WIN_TIME_ADDED} mins.")
      end
    when :duel
      send_chat("#{value[:current_captain]} thinks #{value[:captain]} is unworthy of the wheel and challenges them to a duel!")
      if value[:success] == true
        send_chat("#{value[:current_captain]} defended their Captainship.")
        send_chat("#{value[:captain]} will spend the next #{DoubloonScape::BRIG_DURATION} mins in the brig.")
      else
        send_chat("#{value[:captain]} bested #{value[:current_captain]} in a duel and secured Captain for the next #{DoubloonScape::WIN_TIME_ADDED} mins.")
      end
    end
  end

  def self.treasure_event(value)
    send_chat("#{value[:captain]} has looted the treasure chest! It contained #{value[:gold]} gold!")
  end

  def self.pickpocket_event(value)
    if value[:success] == true
      send_chat("#{value[:rogue]} pickpocketed #{value[:gold]} gold from #{value[:captain]}!")
    else
      send_chat("#{value[:rogue]} tried to pickpocket #{value[:captain]} and failed.")
    end
  end

  def self.battle_event(value)
    send_chat("#{value[:enemy]} has set seige to the ship!")
    if value[:success] == true
      send_chat("#{value[:captain]} has sent #{value[:enemy]} to Davy Jones's Locker and gains #{DoubloonScape::BATTLE_WIN_AMOUNT}% XP!")
      if !value[:item_name].nil?
        send_chat("#{value[:captain]} claimed a trophy! #{value[:item_name]}, #{value[:item_description]}")
      end
    else
      send_chat("#{value[:captain]} narrowly escaped from #{value[:enemy]}!")
    end
  end

  def self.tailwind_event(value)
    send_chat("TAILWIND! #{value[:captain]} is catching up by #{value[:amount]}x!")
  end

  def self.high_seas_event(value)
    if value[:high_seas] == true
      send_chat("HIGH SEAS! The sailors are growing restless!")
    else
      send_chat("CALM WATERS! The sailors are content.")
    end
  end

  def self.ghost_captain_event(value)
    send_chat("GHOST CAPTAIN! #{value[:ghost]} swindles #{value[:captain]} out of #{value[:amount]} gold!")
  end

  def self.keelhaul_event(value)
    send_chat("#{value[:captain]} has called for #{value[:sailor]} to be KEELHAULED!")
    send_chat("#{value[:amount]} gold falls into the sea while overboard.")
  end

  def self.whirlpool_event(value)
    send_chat("Grab something and hold on tight, the ship is circling a WHIRLPOOL!")
  end

  def self.whirlpool_escape_event(value)
    if value[:escape] == true
      send_chat("The ship has escaped the WHIRLPOOL!")
    else
      send_chat("The ship tips on its side! #{value[:amount]} gold falls into the abyss!")
    end
  end

  def self.holiday_event(value)
    if value[:pirates_day] == true
      send_chat("PIRATES DAY! Increased chance of finding items today! \@here")
    end
  end

  def self.offline_captain_event(value)
    Bot.set_game(nil)
  end
end

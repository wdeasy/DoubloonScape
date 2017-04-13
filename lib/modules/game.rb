module Bot
  def self.game_loop
    last_tick = Time.now
    while true do
      if (Time.now - last_tick) >= DOUBLOONSCAPE.seconds && DOUBLOONSCAPE.pause == false
        last_tick += DOUBLOONSCAPE.seconds
        DOUBLOONSCAPE.update_captains_status(get_members_status)
        send_events(DOUBLOONSCAPE.do_turn)
        update_topic(DOUBLOONSCAPE.status)
      end
      sleep 0.1
    end
  end

  def self.update_topic(status)
    case status
    when :paused
      set_topic("This ship is anchored in time.")
    when :nocaptain
      set_topic("Who is the Captain of this Ship!?")
    when :captainoffline
      set_topic("#{DOUBLOONSCAPE.current_name('landlubber')} has abandoned ship!")
    else
      level = status[:level]
      gold  = status[:gold].floor.to_i
      time  = minutes(status[:current])
      ttl   = (((status[:next] / DOUBLOONSCAPE.amount) * DOUBLOONSCAPE.seconds)/60).ceil.to_i
      ttl   = ttl >= 0 ? ttl : 0
      set_topic("Level: #{level} Gold: #{gold} Time as Captain: #{time} min. Next Level: #{ttl} min.")
    end
  end

  def self.update_roles(user)
    role = find_role
    unless DOUBLOONSCAPE.previous_captain.nil?
      revoke_role(get_member(DOUBLOONSCAPE.previous_captain), role)
    end

    unless DOUBLOONSCAPE.current_captain.nil?
      grant_role(user, role)
    end
  end

  def self.update_names
    unless DOUBLOONSCAPE.previous_captain.nil?
      set_name(DOUBLOONSCAPE.previous_captain, DOUBLOONSCAPE.previous_name)
    end
    unless DOUBLOONSCAPE.current_captain.nil?
      set_name(DOUBLOONSCAPE.current_captain, DOUBLOONSCAPE.current_name)
    end
  end

  def self.send_events(events)
    events.each do |key, value|
      if !value.nil?
        case key
        when :achieve
          value.each do |name, description|
            send_chat("Achievement Unlocked! #{name} - #{description}")
          end
        when :bonus
          send_chat("First Captain of the Day Bonus!")
        when :level
          send_chat("#{value[:name]} has hit level #{value[:level]}!")
        when :record
          send_chat("#{value[:name]} has broken their previous record of #{minutes(value[:record])} min. spent as Captain!")
        when :event
          unless value.empty?
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
        when :item
          unless value.empty?
            if value[:quality] == :unique
              send_chat("#{value[:captain]} found a unique item! #{value[:name]}[#{value[:ilvl]}]")
              send_chat("\"#{value[:description]}\"")
            else
              send_chat("#{value[:captain]} found a common #{value[:name]}[#{value[:ilvl]}].")
            end
          end
        when :contest
          unless value.empty?
            case value[:event]
            when :mutiny
              mutineers = "#{value[:mutineers].join(", ")}"
              send_chat("#{mutineers} think #{value[:captain]} is unworthy of the wheel and have called for a mutiny!")
              if value[:success] == true
                send_chat("The mutineers have overthrown the Captain!. #{value[:captain]} will spend the next #{DoubloonScape::BRIG_DURATION} mins in the brig.")
              else
                send_chat("#{value[:captain]} successfully held off the mutiny and secured Captain for the next #{DoubloonScape::WIN_TIME_ADDED} mins.")
              end
            when :duel
              send_chat("#{value[:current_captain]} thinks #{value[:captain]} is unworthy of the wheel and challenges them to a duel!")
              if value[:success] == true
                send_chat("#{value[:current_captain]} defended their Captainship. #{value[:captain]} will spend the next #{DoubloonScape::BRIG_DURATION} mins in the brig.")
              else
                send_chat("#{value[:captain]} bested #{value[:current_captain]} in a duel and secured Captain for the next #{DoubloonScape::WIN_TIME_ADDED} mins.")
              end
            end
          end
        when :treasure
          unless value.empty?
            send_chat("#{value[:captain]} has looted the treasure chest! It contained #{value[:gold]} gold!")
          end
        when :pickpocket
          unless value.empty?
            if value[:success] == true
              send_chat("#{value[:rogue]} pickpocketed #{value[:gold]} gold from #{value[:captain]}!")
            else
              send_chat("#{value[:rogue]} tried to pickpocket #{value[:captain]} and failed.")
            end
          end
        when :battle
          unless value.empty?
            send_chat("#{value[:enemy]} has set seige to the ship!")
            if value[:success] == true
              send_chat("#{value[:captain]} has sent #{value[:enemy]} to Davy Jones's Locker!")
              if !value[:item_name].nil?
                send_chat("#{value[:captain]} claimed a trophy! #{value[:item_name]}, #{value[:item_description]}")
              end
            else
              send_chat("#{value[:captain]} narrowly escaped from #{value[:enemy]}!")
            end
          end
        when :tailwind
          unless value[:amount] == 1
            send_chat("TAILWIND! #{value[:captain]} is catching up by #{value[:amount]}x!")
          end
        end
      end
    end
  end

  def self.is_legit(event)
    legit = false
    unless event.message.channel.pm?
      unless event.author.bot_account?
        unless event.channel.id.to_i != CONFIG.channel
          legit = true
        end
      end
    end
    return legit
  end

  def self.remove_captains
    role = find_role
    BOT.server(CONFIG.server).users.each do |user|
      user.roles.each do |r|
        if r.id.to_i == CONFIG.role
          revoke_role(user, role)
        end
      end
    end
  end

  def self.reset_captain
    id = DOUBLOONSCAPE.current_captain
    unless id.nil?
      capn = get_member(id)
      if !capn.nil? && capn.status != :offline
        Bot.send_chat("Continuing with Captain #{capn.username}")
        role = find_role
        grant_role(capn, role)
      end
    end
  end

  def self.minutes(seconds)
    (seconds/60).floor.to_i
  end
end

module Bot
  def self.game_loop
    last_tick = Time.now
    disc_count = 0
    while true do
      Thread.stop if $exit
      if (Time.now - last_tick) >= DOUBLOONSCAPE.seconds && DOUBLOONSCAPE.pause == false && DOUBLOONSCAPE.locked == false
        if ((Time.now - $start_time).to_i / (24 * 60 * 60)) >= CONFIG.uptime
          Bot.log "A bescheduled restartening, it seems."
          Bot.send_chat("Swabbin' the poop deck!")
          $exit = true
          DOUBLOONSCAPE.stop
          Bot.remove_captains
          unless DOUBLOONSCAPE.current_captain.nil?
            Bot.set_name(DOUBLOONSCAPE.current_captain, DOUBLOONSCAPE.current_name('landlubber'))
          end
          Bot.set_topic(nil)
          BOT.game = nil
          exit 0
        end

        if Time.now.day != last_tick.day
          gc_start = Time.now
          GC.start
          Bot.log "Garbage Collection #{Time.now - gc_start} seconds."
        end

        last_tick = Time.now
        if BOT.connected?
          DOUBLOONSCAPE.update_captains_status(get_members_status)
          send_events(DOUBLOONSCAPE.do_turn)
          update_topic(DOUBLOONSCAPE.status)
          disc_count = 0
          Bot.log "Time elapsed #{(Time.now - last_tick).round(2)} seconds."
        else
          disc_count+=1
          Bot.log "Skipping tick. Bot is disconnected. [#{disc_count}]"
        end
      end
      sleep 0.1
    end
  end

  def self.health_bar(current, max, width)
    divisor = (max.to_f / width)
    life = (current.to_f / divisor).ceil.to_i

    i=0

    healthbar = "|"
    while i < life do
      healthbar += "█"
      i+=1
    end

    while i < width do
      healthbar += "░"
      i+=1
    end
    healthbar += "|"

    return healthbar
  end

  def self.update_topic(status)
    case status
    when :paused
      set_topic("This ship is anchored in time.")
    when :inwhirlpool
      set_topic("The ship is caught in a whirlpool!")
    when :inraid
      raid_info = DOUBLOONSCAPE.raid_info
      if raid_info[:boss_name].nil?
        set_topic("The ship is on a raid!")
      else
        hb = health_bar(raid_info[:boss_current_hp],raid_info[:boss_hp],27)
        percent = ((raid_info[:boss_current_hp].to_f/raid_info[:boss_hp]).round(2)*100.ceil).to_i
        set_topic("#{raid_info[:boss_name]} #{hb} #{percent}%")
      end
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
      topic = "Level: #{level} Gold: #{gold} Time as Captain: #{time} min."
      unless level == DoubloonScape::MAX_LEVEL
         topic << " Next Level: #{ttl} min."
      end
      set_topic(topic)
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
      unless value.nil? || value.empty?
        case key
        when :achieve
          achieve_event(value)
        when :bonus
          bonus_event(value)
        when :level
          level_event(value)
        when :record
          record_event(value)
        when :event
          event_event(value)
        when :item
          item_event(value)
        when :contest
          contest_event(value)
        when :treasure
          treasure_event(value)
        when :pickpocket
          pickpocket_event(value)
        when :battle
          battle_event(value)
        when :tailwind
          tailwind_event(value)
        when :high_seas
          high_seas_event(value)
        when :ghost_captain
          ghost_captain_event(value)
        when :keelhaul
          keelhaul_event(value)
        when :whirlpool
          whirlpool_event(value)
        when :whirlpool_escape
          whirlpool_escape_event(value)
        when :raid
          raid_event(value)
        when :in_raid
          in_raid_event(value)
        when :lootbox
          lootbox_event(value)
        when :holiday
          holiday_event(value)
        when :offline_captain
          offline_captain_event(value)
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
        Bot.set_game(DOUBLOONSCAPE.current_name('landlubber'))
      end
    end
  end

  def self.minutes(seconds)
    (seconds/60).floor.to_i
  end

  def self.log(message)
    puts "[#{Time.now.strftime("%d/%m/%y %H:%M:%S")}] -- #{message}"
  end
end

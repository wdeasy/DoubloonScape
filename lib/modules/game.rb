module Bot
  def self.game_loop
    last_tick = Time.now
    disc_count = 0
    while true do
      log "top of loop" if DOUBLOONSCAPE.debug
      Thread.stop if $exit
      if (Time.now - last_tick) >= DOUBLOONSCAPE.seconds && DOUBLOONSCAPE.pause == false && DOUBLOONSCAPE.locked == false
        log "update last tick" if DOUBLOONSCAPE.debug
        last_tick = Time.now
        if BOT.connected?
          log "update captain status" if DOUBLOONSCAPE.debug
          DOUBLOONSCAPE.update_captains_status(get_members_status)
          log "do turn" if DOUBLOONSCAPE.debug
          send_events(DOUBLOONSCAPE.do_turn)
          log "update topic" if DOUBLOONSCAPE.debug
          update_topic(DOUBLOONSCAPE.status)
          disc_count = 0

          if Time.now.min % 10 == 0
            Bot.log "Time elapsed #{(Time.now - last_tick).round(2)} seconds."
          end
        else
          disc_count+=1
          Bot.log "Skipping tick. Bot is disconnected. [#{disc_count}]"
        end
      else
        log "#{Time.now} - #{last_tick} >= #{DOUBLOONSCAPE.seconds}" if @debug
      end
      sleep 0.1
      log "bottom of loop" if @debug
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
    when :inwhirlpool
      set_topic("The ship is caught in a whirlpool!")
    when :inraid
      raid_info = DOUBLOONSCAPE.raid_info
      if raid_info[:current_boss].nil?
        set_topic("Captains Alive: #{raid_info[:captains_alive]}")
      else
        set_topic("Current Boss: #{raid_info[:boss_name]}. HP: #{raid_info[:boss_hp]}. Captains Alive: #{raid_info[:captains_alive]}")
      end
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

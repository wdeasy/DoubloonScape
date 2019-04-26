require 'yaml/store'

module DoubloonScape
  class Game
    attr_reader :brig, :pause, :cooldown, :locked

    def initialize
      #events
      @events = DoubloonScape::Event.new

      #captains
      @captains = Hash.new
      @cooldown = Time.now - seconds

      #past 50 captains
      @chain = Array.new(50)

      #game state
      @pause = true
      @locked = false

      #save data
      @store = YAML::Store.new(DoubloonScape::CAPTAINS)

      #jailed captains
      @brig = Hash.new

      #treasure
      @treasure = 1

      #high seas
      @high_seas = false

      #save queue
      @save_queue = Array.new()
      @chain_updated = false
    end

    def captain(id)
      @captains[id]
    end

    def finish_captain(id, stop)
      #stops current captain
      unless id.nil?
        @captains[id].update_record
        unless stop
          @captains[id].current = 0
        end
        @captains[id].offline = 0
        @captains[id]
        add_to_queue(id)
        @chain_updated = true
      end
    end

    def load_captain(id, name)
      @loading = true
      if @captains[id].nil?
        new_captain = DoubloonScape::Captain.new(id)
        @captains[id] = new_captain
        #temp solution
        season = [154437803562762240,
                  165313516985778176,
                  247181674620649472,
                  160619908063952907,
                  165489755620900864,
                  248626841164840961,
                  164140817718575106,
                  165613111368351744,
                  165310768286400513,
                  195331188540309505,
                  165310795360632832,
                  211679729428856832,
                  95203364001812480]
        if season.include? id
          @captains[id].achieves.add_value('alpha', 1)
        end

        firstplace = [165489755620900864,
                      164140817718575106]
        if firstplace.include? id
          @captains[id].achieves.add_value('firstplace', 1)
        end
        ############
      end
      @captains[id].update_name(name)
      @loading = false
    end

    def change_captains(id, name)
      pre = current_captain
      cur = id

      @cooldown = Time.now + seconds
      events = {}

      unless cur == pre
        #load or create the new captain
        load_captain(cur, name)
        events[:contest] = contest_check(cur, pre)

        if events[:contest].empty? || events[:contest][:success] == false
          @chain.push(cur)
          @chain.shift

          #save old captain
          finish_captain(pre, false)

          #achievement checks
          unless pre.nil?
            denier_check(cur, pre)
            chain_check(cur)
            if @captains[pre].status == :offline
              events[:ghost_captain] = ghost_captain_check(pre, cur)
              @captains[cur].achieves.add_value('necro', 1)
            end
          end

          #start new captain
          events[:bonus] = @captains[cur].bonus_check
          @captains[cur].time_started
          @captains[cur].update_count
          events[:high_seas] = high_seas_check
          events[:achieve] = @captains[cur].achieve_check
          events[:tailwind] = tailwind_check(cur)
        end
      end
      return events
    end

    def current_captain
      if @chain[-1].nil?
      	return nil
      else
        return @chain[-1]
      end
    end

    def previous_captain
      if @chain[-2].nil?
      	return nil
      else
        return @chain[-2]
      end
    end

    def current_name(landlubber=nil)
      cur = current_captain
      if landlubber.nil?
        @captains[cur].captain_name
      else
        @captains[cur].landlubber_name
      end
    end

    def previous_name
      @captains[previous_captain].landlubber_name
    end

    def save_captain(id)
      begin
        @store.transaction do
          capns = @store.fetch('captains', Array.new)
          unless capns.include? id
            capns.push(id)
            @store['captains'] = capns
          end
          @store[id] = @captains[id]
        end
      rescue PStore::Error => msg
        log "Unable to save captain #{id}."
        log msg
      end
    end

    def save_captains
      begin
        @store.transaction do
          capns = Array.new
          @captains.each do |id, capn|
            capns.push(id)
            @store[id] = capn
          end
          @store['captains'] = capns
          @store['chain']    = @chain
          @store['treasure'] = @treasure
        end
      rescue PStore::Error => msg
        log "Unable to save all captains."
        log msg
      end
    end

    def save_chain
      begin
        @store.transaction do
          @store['chain'] = @chain
        end
      rescue PStore::Error => msg
        log "Unable to save chain."
        log msg
      end
    end

    def load_captains
      @store.transaction do
        capns = @store.fetch('captains', Array.new)
        unless capns.nil?
          capns.each do |capn|
            @captains[capn] = @store[capn]
            @captains[capn].achieves.load_realm_firsts
            @captains[capn].last_update = Time.now
            @captains[capn].update_record
          end
        end
        @chain = @store.fetch('chain', Array.new(50))
        @treasure = @store.fetch('treasure', 1)
      end
      cur = current_captain
      if cur.nil? || @captains[cur].status == :offline
        @chain.push(nil)
        @chain.shift
      end
    end

    def start
      @pause = false
    end

    def stop
      @pause = true
      cur = current_captain
      unless cur.nil?
        finish_captain(cur, true)
      end
      save_captains
    end

    def amount(id=current_captain)
      (DoubloonScape::AMOUNT + @events.amount_modifier) * @captains[id].tailwind
    end

    def seconds
      DoubloonScape::SECONDS + @events.time_modifier
    end

    def update_captain(id)
      unless @captains[id].status == :offline
        time = (Time.now - @captains[id].last_update)
        if id == current_captain
          @captains[id].give_xp(amount(id))
          @captains[id].give_gold(amount(id))
        end
        @captains[id].update_current(time)
        @captains[id].update_total(time)
      end
      @captains[id].last_update = Time.now
    end

    def do_turn
      events = {}
      if @events.in_whirlpool == true
        events[:whirlpool_escape] = whirlpool_escape_check
      else
        capn = current_captain
        unless @pause == true
          brig_check
          events[:whirlpool] = @events.whirlpool_check
          events[:holiday] = @events.holiday_check
          events[:event] = event_check(capn)
          unless capn.nil?
            update_captain(capn)
            if @captains[capn].status == :offline
              if @captains[capn].offline == 1
                events[:offline_captain] = true
              end
            else
              events[:pickpocket] = pickpocket_check(capn)
              events[:battle] = battle_check(capn)
              events[:keelhaul] = keelhaul_check(capn)
              events[:treasure] = treasure_check(capn)
              events[:item] = @captains[capn].item_check
              events[:level] = @captains[capn].level_check
              events[:lootbox] = lootbox_check(capn)
              unless events[:level].nil?
                events[:tailwind] = tailwind_check(capn)
              end
              events[:record] = @captains[capn].record_check
            end
            events[:achieve] = @captains[capn].achieve_check
            add_to_queue(capn)
          end
        end
      end

      process_queue
      return events
    end

    def high_seas_check
      display = Hash.new
      capns = @chain[40..-1]

      unless capns.nil?
        uniq = capns.uniq.count

        if uniq > 4 && @high_seas == false
          display = {:high_seas => true}
          @high_seas = true
        elsif uniq < 5 && @high_seas == true
          display = {:high_seas => false}
          @high_seas = false
        end
      end

      return display
    end

    def denier_check(cur=current_captain, pre=previous_captain)
      if @captains[pre].next_level - @captains[pre].xp < 2
        @captains[cur].achieves.add_value('denies', 1)
      end
    end

    def chain_check(cur=current_captain)
      [10,20,50].each do |num|
        count = 0
        capns = Array.new
        ((50-num)..49).each do |n|
          capn = @chain[n]
          unless capn.nil?
            unless capns.include? capn
              capns.push(capn)
            end
            if capn == @captains[cur].id
              count += 1
            end
          end
        end
        if count == num/2
          @captains[cur].achieves.add_value("nemesis#{num/2}", 1)
          if capns.count == 2
            @captains[cur].achieves.add_value("challenger#{num/2}", 1)
          end
        end
      end
    end

    def event_check(cur=current_captain)
      event = @events.event_check
      current_events = @events.current_events

      unless cur.nil? || @captains[cur].status == :offline
        if !event.empty? && !cur.nil?
          if event[:place] == 'atlantis'
            @captains[cur].achieves.add_value('atlantis', 1)
            if current_events.include? 'bermuda triangle'
              @captains[cur].achieves.add_value('atlamuda', 1)
            end
          end
          if event[:place] == 'bermuda triangle'
            @captains[cur].achieves.add_value('bermuda', 1)
            if current_events.include? 'atlantis'
              @captains[cur].achieves.add_value('atlamuda', 1)
            end
          end
        end
      end

      return event
    end

    def online_captains(cur=current_captain)
      cpns = @captains
      online = Array.new
      unless cpns.nil?
        cpns.each do |id, capn|
          if capn.status != :offline && id != cur && !(@brig.key? id)
            online.push(capn.id)
          end
        end
      end
      return online
    end

    def contest_check(cur, pre)
      contest = {}

      if @high_seas == true
        multiplier = DoubloonScape::HIGH_SEAS_MULTIPLIER
      else
        multiplier = 1
      end

      if !pre.nil? && @captains[pre].status != :offline
        if rand(100/multiplier) < DoubloonScape::CONTEST_CHANCE
          events = []
          capns = online_captains(cur)
          capns.delete(pre)

          if Time.now > @events.duel_cooldown
            events.push('duel')
          end

          if capns.count >= DoubloonScape::MUTINEER_COUNT && Time.now > @events.mutiny_cooldown
            events.push('mutiny')
          end

          event = events.sample
          if event == 'mutiny'
            mutineers = Hash.new
            capns.sample(DoubloonScape::MUTINEER_COUNT).each do |mutineer|
              mutineers[mutineer] = @captains[mutineer]
            end
            contest = @events.mutiny(@captains[cur], mutineers)
          elsif event == 'duel'
            contest = @events.duel(@captains[cur], @captains[pre])
          end
        end
      end

      unless contest.empty?
        if contest[:success] == true
          @brig[cur] = Time.now + DoubloonScape::BRIG_DURATION.minutes
          case contest[:event]
          when :mutiny
            mutineers.each do |id, capn|
              amt = @captains[id].next_level * (DoubloonScape::MUTINEER_BONUS * 0.01)
              @captains[id].give_xp(amt)
              add_to_queue(id)
            end
          when :duel
            amt = @captains[pre].next_level * (DoubloonScape::DUEL_BONUS * 0.01)
            @captains[pre].give_xp(amt)
            add_to_queue(pre)
          end
        else
          @cooldown = Time.now + DoubloonScape::WIN_TIME_ADDED.minutes
          @captains[cur].achieves.add_value(event, 1)
        end
      end

      return contest
    end

    def brig_check
      unless @brig.empty?
        @brig.each do |brigged, release_time|
          if Time.now > release_time
            @brig.delete(brigged)
          end
        end
      end
    end

    def pickpocket_check(cur=current_captain)
      pickpocket = Hash.new
      if rand(100) < DoubloonScape::PICKPOCKET_CHANCE && Time.now > @events.pickpocket_cooldown
        capns = online_captains(cur)
        rogue = capns.sample
        unless capns.empty?
          multiplier = level_rank(cur)
          pickpocket = @events.pickpocket(@captains[cur], @captains[rogue], multiplier)

          if pickpocket[:success] == true
            @captains[cur].take_gold(pickpocket[:gold])
            @captains[rogue].give_gold(pickpocket[:gold])
            add_to_queue(rogue)
          end
        end
      end
      return pickpocket
    end

    def ghost_captain_check(ghost, capn)
      ghost_capn = Hash.new

      if rand(100) < DoubloonScape::GHOST_CAPTAIN_CHANCE
        multiplier = level_rank(capn)
        pickpocket = @events.pickpocket(@captains[capn], @captains[ghost], multiplier)
        if pickpocket[:success] == true
          @captains[capn].take_gold(pickpocket[:gold])
          @captains[ghost].give_gold(pickpocket[:gold])
          add_to_queue(ghost)
          add_to_queue(capn)
          ghost_capn[:ghost]   = @captains[ghost].landlubber_name
          ghost_capn[:captain] = @captains[capn].landlubber_name
          ghost_capn[:amount] = pickpocket[:gold]
        end
      end

      return ghost_capn
    end

    def keelhaul_check(cur)
      keelhaul = Hash.new
      if rand(1000) < (DoubloonScape::KEELHAUL_CHANCE*10)
        capns = online_captains(cur)
        if capns.count > 1
          sailor = capns.sample
          multiplier = level_rank(sailor)
          pickpocket = @events.pickpocket(@captains[sailor], @captains[cur], multiplier)
          if pickpocket[:success] == true
            @captains[sailor].take_gold(pickpocket[:gold])
            @treasure += pickpocket[:gold]
            add_to_queue(sailor)
            keelhaul[:captain] = @captains[cur].landlubber_name
            keelhaul[:sailor] = @captains[sailor].landlubber_name
            keelhaul[:amount] = pickpocket[:gold]
          end
        end
      end
      return keelhaul
    end

    def lootbox_check(cur)
      loot = Hash.new
        if rand(1000) < (DoubloonScape::LOOTBOX_CHANCE*10) && @captains[cur].gold > DoubloonScape::LOOTBOX_PRICE
          until !loot.empty?
            loot = @captains[cur].item_check
          end
          @captains[cur].take_gold(DoubloonScape::LOOTBOX_PRICE)
          @treasure += DoubloonScape::LOOTBOX_PRICE
        end
      return loot
    end

    def battle_check(cur=current_captain)
      battle = Hash.new
      unless @captains[cur].level < DoubloonScape::BATTLE_MIN_LEVEL
        if rand(100) < DoubloonScape::BATTLE_CHANCE && Time.now > @events.battle_cooldown
          max_roll = @captains[@captains.max_by{|id,capn| capn.roll}[0]].roll
          battle = @events.battle(@captains[cur], max_roll)

          if battle[:success] == true
            amt = @captains[cur].next_level * (DoubloonScape::BATTLE_WIN_AMOUNT * 0.01)
            @captains[cur].give_xp(amt)
            @captains[cur].achieves.add_value(battle[:enemy], 1)
            if battle[:item] == true
              battle = @captains[cur].inv.battle_item(battle)
              if !battle[:item_name].nil?
                @captains[cur].achieves.add_value('uniques', 1)
                @captains[cur].achieves.set_values('ilvl', @captains[cur].inv.ilvl)
              end
            end
          end
        end
      end
      return battle
    end

    def treasure_check(cur=current_captain)
      treasure = {}
      if rand(1000) < (DoubloonScape::TREASURE_CHANCE*10)
        treasure ={:captain => @captains[cur].landlubber_name, :gold => @treasure}
        @captains[cur].give_gold(@treasure)
        @captains[cur].achieves.add_value('treasures', 1)
        @treasure = 0
      else
        @treasure += 1
      end
      return treasure
    end

    def level_rank(cur)
      capns = @captains
      if cur.nil? || capns.empty?
        return 1
      end

      level = Hash.new
      sorted = Hash.new

      capns.each do |id, capn|
        level[id] = capn.level
      end

      sorted = level.sort_by { |id, level| level }.reverse

      rank = sorted.find_index { |k,_| k== cur }+1

      if rank < 1
        return 1
      else
        return rank
      end
    end

    def tailwind_check(cur)
      rank = level_rank(cur)
      amt = rank * DoubloonScape::TAILWIND_MULTIPLIER

      if @captains[cur].tailwind == amt && @captains[cur].current > 0
        return {:captain => @captains[cur].landlubber_name, :amount => DoubloonScape::TAILWIND_MULTIPLIER}
      else
        @captains[cur].tailwind = amt
        return {:captain => @captains[cur].landlubber_name, :amount => amt}
      end
    end

    def status
      cur = current_captain
      if @paused == true
        return :paused
      elsif cur.nil?
        return :nocaptain
      elsif @captains[cur].status == :offline
        return :captainoffline
      else
        capn = @captains[cur]
        return {:level => capn.level, :gold => capn.gold, :current => capn.current, :next => capn.next}
      end
    end

    def update_captains_status(statuses)
      cur = current_captain
      cpns = @captains
      unless cpns.nil?
        cpns.each do |capn_id, capn|
          statuses.each do |id, status|
            if capn_id == id
              if capn_id == cur && !cur.nil?
                if status == :offline
                  @captains[capn_id].offline += 1
                  if @captains[capn_id].offline == DoubloonScape::OFFLINE
                    @captains[capn_id].achieves.add_value('deserter', 1)
                  end
                else
                  @captains[capn_id].offline = 0
                end
              end
              capn.status = status
            end
          end
        end
      end
    end

    def leaderboard
      level  = Hash.new
      ilvl   = Hash.new
      gold   = Hash.new

      capns = @captains

      capns.each do |id, capn|
        level[id]  = capn.level
        ilvl[id]   = capn.inv.ilvl
        gold[id]   = capn.gold
      end

      sorted = Hash.new
      sorted[:level]  = level.sort_by { |id, level| level }.reverse
      sorted[:ilvl]   = ilvl.sort_by { |id, ilvl| ilvl }.reverse
      sorted[:gold]   = gold.sort_by { |id, gold| gold }.reverse

      max = Hash.new
      max[:level]     = level.max_by { |id, level| level }
      max[:ilvl]      = ilvl.max_by { |id, ilvl| ilvl }
      max[:gold]      = gold.max_by { |id, gold| gold }

      leaderboard = Hash.new
      capns.each do |id, capn|
        score = 0.to_f

        sorted[:level].each do |level_id, level|
          if level_id == id
            weighted_level = (max[:gold][1] * (level.to_f / max[:level][1]))
            score += weighted_level
          end
        end

        sorted[:ilvl].each do |ilvl_id, ilvl|
          if ilvl_id == id
            weighted_ilvl = (max[:gold][1] * (ilvl.to_f / max[:ilvl][1]))
            score += weighted_ilvl
          end
        end

        sorted[:gold].each do |gold_id, gold|
          if gold_id == id
            weighted_gold = (max[:gold][1] * (gold.to_f / max[:gold][1]))
            score += weighted_gold
          end
        end

        if score < 0
          score = 0.to_f
        end

        leaderboard[capn.landlubber_name] = {:score => score.floor.to_i, :level => capn.level, :ilvl => capn.inv.ilvl, :gold => capn.gold}
      end

      sorted_leaderboard = leaderboard.sort_by {|name, hash| hash[:score] }.reverse
      return sorted_leaderboard
    end

    #locks to try to stop weird things from happening
    #when i'm the captain now is being spammed

    def lock
      @locked = true
    end

    def unlock
      @locked = false
    end

    def log(message)
      puts "[#{Time.now.strftime("%d/%m/%y %H:%M:%S")}] -- #{message}"
    end

    def add_to_queue(id)
      @save_queue.push(id) unless @save_queue.include?(id)
    end

    def process_queue
      until @save_queue.empty?
        id = @save_queue.pop
        save_captain(id)
      end

      if @chain_updated == true
        @chain_updated = false
        save_chain
      end
    end

    def whirlpool_escape
      whirlpool = Hash.new

      if rand(1000) < (DoubloonScape::WHIRLPOOL_ESCAPE_CHANCE*10)
        whirlpool = {:escape => true}
        @events.in_whirpool = false
      else
        amt = 0
        @captains.each do |capn|
          lost = capn.gold * (DoubloonScape::WHIRLPOOL_AMOUNT*0.01).ceil.to_i
          capn.take_gold(lost)
          amt += lost
        end
        @treasure += gold
        whirlpool = {:escape => false, :amount => amt}
      end

      return whirlpool
    end
  end
end

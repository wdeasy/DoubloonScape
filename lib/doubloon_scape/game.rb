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

      #past 5 captains
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
    end

    def captain(id)
      @captains[id]
    end

    def finish_captain(id)
      #stops current captain
      unless id.nil?
        update_captain(id)
        @captains[id].update_record
        @captains[id].current = 0
        @captains[id].offline = 0
        @captains[id]
        save_captain(id)
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

        firstplace = [165489755620900864]
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
          finish_captain(pre)

          #achievement checks
          unless pre.nil?
            denier_check(cur, pre)
            chain_check(cur)
            if @captains[pre].status == :offline
              @captains[cur].achieves.add_value('necro', 1)
            end
          end

          #start new captain
          events[:bonus] = @captains[cur].bonus_check
          @captains[cur].time_started
          @captains[cur].update_count
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
      @store.transaction do
        capns = @store.fetch('captains', Array.new)
        unless capns.include? id
          capns.push(id)
          @store['captains'] = capns
        end
        @store[id] = @captains[id]
      end
    end

    def save_captains
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
        finish_captain(cur)
      end
      save_captains
    end

    def amount
      (DoubloonScape::AMOUNT + @events.amount_modifier) * @captains[current_captain].tailwind
    end

    def seconds
      DoubloonScape::SECONDS + @events.time_modifier
    end

    def update_captain(id)
      unless @captains[id].locked == true
        @captains[id].lock
        unless @captains[id].status == :offline
          time = (Time.now - @captains[id].last_update)
          if id == current_captain
            @captains[id].give_xp(amount)
            @captains[id].give_gold(amount)
          end
          @captains[id].update_current(time)
          @captains[id].update_total(time)
        end
        @captains[id].last_update = Time.now
        @captains[id].unlock
      end
    end

    def do_turn
      events = {}
      capn = current_captain
      unless @pause == true
        brig_check
        events[:event] = event_check(capn)
        unless capn.nil?
          update_captain(capn)
          unless @captains[capn].status == :offline
            events[:pickpocket] = pickpocket_check(capn)
            events[:battle] = battle_check(capn)
            events[:treasure] = treasure_check(capn)
            events[:item] = @captains[capn].item_check
            events[:level] = @captains[capn].level_check
            unless events[:level].nil?
              tailwind_check(capn)
            end
            events[:record] = @captains[capn].record_check
          end
          events[:achieve] = @captains[capn].achieve_check
          save_captain(capn)
        end
      end
      return events
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
      if rand(100) < DoubloonScape::CONTEST_CHANCE
        events = []
        capns = online_captains(cur)
        capns.delete(pre)

        if !pre.nil? && Time.now > @events.duel_cooldown
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

      unless contest.empty?
        if contest[:success] == true
          @brig[cur] = Time.now + DoubloonScape::BRIG_DURATION.minutes
          case contest[:event]
          when :mutiny
            mutineers.each do |id, capn|
              amount = @captains[id].next_level * DoubloonScape::MUTINEER_BONUS
              @captains[id].give_xp(amount)
              save_captain(id)
            end
          when :duel
            amount = @captains[pre].next_level * DoubloonScape::DUEL_BONUS
            @captains[pre].give_xp(amount)
            save_captain(pre)
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
          pickpocket = @events.pickpocket(@captains[cur], @captains[rogue])

          if pickpocket[:success] == true
            @captains[cur].take_gold(pickpocket[:gold])
            @captains[rogue].give_gold(pickpocket[:gold])
            save_captain(rogue)
          end
        end
      end
      return pickpocket
    end

    def battle_check(cur=current_captain)
      battle = Hash.new
      unless @captains[cur].level < DoubloonScape::BATTLE_MIN_LEVEL
        if rand(100) < DoubloonScape::BATTLE_CHANCE && Time.now > @events.battle_cooldown
          max_roll = @captains[@captains.max_by{|id,capn| capn.roll}[0]].roll
          battle = @events.battle(@captains[cur], max_roll)

          if battle[:success] == true
            amount = @captains[cur].next_level * DoubloonScape::BATTLE_WIN_AMOUNT
            @captains[cur].give_xp(amount)
            @captains[cur].achieves.add_value(battle[:enemy], 1)
            if battle[:item] == true
              battle = @captains[cur].inv.battle_item(battle)
            end
          end
        end
      end
      return battle
    end

    def treasure_check(cur=current_captain)
      treasure = {}
      if rand(1000) < DoubloonScape::TREASURE_CHANCE
        treasure ={:captain => @captains[cur].landlubber_name, :gold => @treasure}
        @captains[cur].give_gold(@treasure)
        @captains[cur].achieves.add_value('treasures', 1)
        @treasure = 0
      else
        @treasure += 1
      end
      return treasure
    end

    def tailwind_check(cur)
      capns = @captains
      levels = 0
      top = 0

      capns.each do |id, capn|
        levels += capn.level

        if capn.level > top 
          top = capn.level
        end
      end

      avg = levels / capns.count

      if @captains[cur].level < avg && @captains[cur].level < top
        @captains[cur].tailwind = DoubloonScape::TAILWIND_MULTIPLIER
      else
        @captains[cur].tailwind = 1
      end

      return {:captain => @captains[cur].landlubber_name, :amount => @captains[cur].tailwind}
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
  end
end

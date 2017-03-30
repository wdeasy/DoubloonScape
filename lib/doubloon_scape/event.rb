module DoubloonScape
  class Event
  	def initialize
      #atlantis gold modifier
  		@atlantis_start    = nil
  		@atlantis_end      = nil
  		@atlantis_modifier = nil
  		@atlantis_amount   = 0

  		#bermuda time modifier
  		@bermuda_start     = nil
  		@bermuda_end       = nil
  		@bermuda_modifier  = nil
  		@bermuda_amount    = 0

      #contests
      @last_mutiny = Time.now - DoubloonScape::MUTINY_COOLDOWN.minutes
      @last_duel = Time.now - DoubloonScape::DUEL_COOLDOWN.minutes

      @last_battle = Time.now - DoubloonScape::BATTLE_COOLDOWN.minutes
      @last_pickpocket = Time.now - DoubloonScape::PICKPOCKET_COOLDOWN.minutes
  	end

    def mutiny_cooldown
      @last_mutiny + DoubloonScape::MUTINY_COOLDOWN.minutes
    end

    def duel_cooldown
      @last_duel + DoubloonScape::DUEL_COOLDOWN.minutes
    end

    def battle_cooldown
      @last_battle + DoubloonScape::BATTLE_COOLDOWN.minutes
    end

    def pickpocket_cooldown
      @last_pickpocket + DoubloonScape::PICKPOCKET_COOLDOWN.minutes
    end

    def current_events
      events = Array.new
      unless @atlantis_end.nil?
        events.push('atlantis')
      end
      unless @bermuda_end.nil?
        events.push('bermuda triangle')
      end
      return events
    end

    def time_modifier
      if @bermuda_start.nil?
        0
      else
        if @bermuda_modifier == :curse
          @bermuda_amount * 0.6
        else
          @bermuda_amount * -0.6
        end
      end
    end

    def amount_modifier
      if @atlantis_start.nil?
        0
      else
        @atlantis_amount * 0.01
      end
    end

    def event_check
    	event = {}
    	if !@atlantis_end.nil? && @atlantis_end < Time.now
    		@atlantis_start    = nil
        @atlantis_end      = nil
        @atlantis_modifier = nil
        @atlantis_amount   = 0
    	elsif !@bermuda_end.nil? && @bermuda_end < Time.now
        @bermuda_start    = nil
        @bermuda_end      = nil
        @bermuda_modifier = nil
        @bermuda_amount   = 0      
    	end
    	
      if @atlantis_start.nil? || @bermuda_start.nil?
        if rand(100) < DoubloonScape::ATLAMUDA_CHANCE
          if !@atlantis_start.nil?
            place = 'bermuda triangle'
          elsif !@bermuda_start.nil?
            place = 'atlantis'
          else
            place = rand(1) == 0 ? 'atlantis' : 'bermuda triangle'
          end

          if place == 'atlantis'
            unit = :goldxp
            modifier = :buff
            amount = rand(1..DoubloonScape::ATLANTIS_MOD_MAX)
          else
            unit = :time
            modifier = rand(2) == 0 ? :buff : :curse
            amount = rand(1..DoubloonScape::BERMUDA_MOD_MAX)
          end

          if place == 'atlantis'
            @atlantis_start = Time.now
            @atlantis_end = Time.now + DoubloonScape::BUFF_DURATION.minutes
            @atlantis_modifier = modifier
            @atlantis_amount = amount
          else
            @bermuda_start = Time.now
            @bermuda_end = Time.now + DoubloonScape::BUFF_DURATION.minutes
            @bermuda_modifier = modifier
            @bermuda_amount = amount
          end
          
          event = {:place => place, :modifier => modifier, :unit => unit, :amount => amount }
        end
      end

    	return event
    end

    def mutiny(captain, mutineers)
      @last_mutiny = Time.now
      captains_roll = rand(captain.inv.ilvl + captain.achieves.count)
      succeed = false
      names = []

      mutineers.each do |id, mutineer|
        names.push(mutineer.landlubber_name)
        roll = rand(mutineer.inv.ilvl + mutineer.achieves.count)
        if roll > captains_roll
          succeed = true
        end
      end

      return {:event => :mutiny, :success => succeed, :captain => captain.landlubber_name, :mutineers => names}
    end

    def duel(captain, current_captain)
      @last_duel = Time.now
      captains_roll = rand(captain.inv.ilvl + captain.achieves.count)
      current_captains_roll = rand(current_captain.inv.ilvl + current_captain.achieves.count)
      succeed = true

      if current_captains_roll < captains_roll
        succeed = false
      end

      return {:event => :duel, :success => succeed, :captain => captain.landlubber_name, :current_captain => current_captain.landlubber_name}
    end

    def battle(captain,max_roll)
      @last_battle = Time.now
      enemies = ['The Kraken','Moby Dick','The Leviathan','A Hydra','The Queen Anne\'s Revenge','Admiral Nelson']
      enemy = enemies.sample
      succeed = false
      item = false

      enemy_roll = rand(max_roll+1)
      captain_roll = rand(captain.roll)

      if captain_roll > enemy_roll
        succeed = true
        if rand(100) < DoubloonScape::BATTLE_ITEM_CHANCE
          item = true
        end
      end

      return {:success => succeed, :enemy => enemy, :captain => captain.landlubber_name, :item => item}
    end

    def pickpocket(captain, rogue)
      @last_pickpocket = Time.now
      pickpocket = Hash.new
      captains_roll = rand(captain.roll)
      rogues_roll = rand(rogue.roll)
      succeed = false
      gold = 0

      if captains_roll < rogues_roll && captain.gold > 0
        succeed = true
        gold = (captain.gold * DoubloonScape::PICKPOCKET_AMOUNT).ceil.to_i
        gold = gold > DoubloonScape::PICKPOCKET_MAX ? ((DoubloonScape::PICKPOCKET_MAX - 10) + rand(10)) : gold
      end

      return {:success => succeed, :captain => captain.landlubber_name, :rogue => rogue.landlubber_name, :gold => gold}
    end
  end
end
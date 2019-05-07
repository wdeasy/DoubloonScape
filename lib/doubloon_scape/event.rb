require 'date'
require 'time'

module DoubloonScape
  class Event
    attr_accessor :in_whirlpool, :in_raid

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
      @last_mutiny     = Time.now - DoubloonScape::MUTINY_COOLDOWN.minutes
      @last_duel       = Time.now - DoubloonScape::DUEL_COOLDOWN.minutes

      @last_battle     = Time.now - DoubloonScape::BATTLE_COOLDOWN.minutes
      @last_pickpocket = Time.now - DoubloonScape::PICKPOCKET_COOLDOWN.minutes

      #whirlpool
      @last_whirlpool  = Time.now - DoubloonScape::WHIRLPOOL_COOLDOWN.minutes
      @in_whirlpool    = false

      #raid
      @last_raid       = Time.now - DoubloonScape::RAID_COOLDOWN.minutes
      @in_raid         = false
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
      if @bermuda_end.nil?
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
      if @atlantis_end.nil?
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

      if @atlantis_end.nil? || @bermuda_end.nil?
        if rand(1000) < (DoubloonScape::ATLAMUDA_CHANCE*10)
          if !@atlantis_end.nil?
            place = 'bermuda triangle'
          elsif !@bermuda_end.nil?
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

    def holiday_check
      event = {}

      if Time.now.hour == 0 && Time.now.min == 0
        case Date.today
        when Date.parse(DoubloonScape::PIRATES_DAY)
          event[:pirates_day] == true
        end
			end

      return event
    end

    def mutiny(captain, mutineers)
      @last_mutiny = Time.now
      captains_roll = rand(captain.roll)
      succeed = false
      names = []

      mutineers.each do |id, mutineer|
        names.push(mutineer.landlubber_name)
        roll = rand(mutineer.roll)
        if roll > captains_roll
          succeed = true
        end
      end

      return {:event => :mutiny, :success => succeed, :captain => captain.landlubber_name, :mutineers => names}
    end

    def duel(captain, current_captain)
      @last_duel = Time.now
      captains_roll = rand(captain.roll)
      current_captains_roll = rand(current_captain.roll)
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

    def pickpocket(captain, rogue, multiplier)
      @last_pickpocket = Time.now
      pickpocket = Hash.new
      captains_roll = rand(captain.roll)
      rogues_roll = rand(rogue.roll)
      succeed = false
      gold = 0

      if captains_roll < rogues_roll && captain.gold > 0
        gold = (rand(captain.gold * (DoubloonScape::PICKPOCKET_MAX * 0.01)) / multiplier).ceil.to_i
        if gold > 0
          succeed = true
        end
      end

      return {:success => succeed, :captain => captain.landlubber_name, :rogue => rogue.landlubber_name, :gold => gold}
    end

    def whirlpool_cooldown
      @last_whirlpool + DoubloonScape::WHIRLPOOL_COOLDOWN.minutes
    end

    def whirlpool_escape
      @in_whirlpool = false
    end

    def whirlpool_check
      whirlpool = {}

      if Time.now > whirlpool_cooldown && @in_raid == false
        if rand(1000) < (DoubloonScape::WHIRLPOOL_CHANCE*10)
          @last_whirlpool = Time.now()
          @in_whirlpool = true
          whirlpool = {:whirlpool => true}
        end
      end

      return whirlpool
    end

    def raid_cooldown
      @last_raid + DoubloonScape::RAID_COOLDOWN.minutes
    end

    def raid_check
      raid = {}

      if Time.now > raid_cooldown && @in_whirlpool == false
        if rand(1000) < (DoubloonScape::RAID_CHANCE*10)
          @last_raid = Time.now()
          @in_raid = true
          raid = {:raid => true}
        end
      end

      return raid
    end
  end
end

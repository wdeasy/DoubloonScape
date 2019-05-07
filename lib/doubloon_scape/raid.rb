module DoubloonScape
  class Raid
    class Boss
			attr_reader :name, :desc, :hp, :lvl, :weapon
	  	def initialize(name, desc, hp, lvl, weapon)
	  		@name = name
	  		@description = desc
        @hp = hp
        @lvl = lvl
        @weapon = weapon
	  	end
	  end

    class Raider
      attr_reader :id, :name, :hp, :lvl, :weapon, :damage
	  	def initialize(id, name, hp, lvl, :weapon, damage)
        @id = id
	  		@name = name
        @hp = hp
        @lvl = lvl
        @weapon = weapon
        @damage = damage
	  	end
    end

    def initialize(capns)
      @status  = :in_progress
      @current_boss = nil
      @bosses  = Array.new
      @raiders = Array.new
      @avg_hp  = 1
      @max_hp  = 1
      @max_lvl = 1

      load_raiders(capns)
      calc_stats(capns)
      load_bosses
    end

    def load_raiders(capns)
      #loop through captains and create an object to track their health
      #health is equal to their ilvl
      capns.each do |id, capn|
        @unique.push({:id => id, :name => capn.landlubber_name, :hp => capn.inv.ilvl, :lvl => capn.level, :weapon => capn.inventory['Main Hand'].name, :damage => capn.inventory['Main Hand'].ilvl)
      end
    end

    def load_bosses
      #load bosses to pick from
      @bosses.push({:name => "Komuz, The Fretless Luter", :desc => "A low-strung bard", :hp => calc_boss_hp, :lvl => @max_lvl, :weapon => ["Healing Tune"]})
      @bosses.push({:name => "Pippy Darkfin", :desc => "Fearlessly charges you.", :hp => calc_boss_hp, :lvl => @max_lvl, :weapon => ["Attack"]})
      @bosses.push({:name => "Pee-Wee Merman", :desc => "A loner, a rebel.", :hp => calc_boss_hp, :lvl => @max_lvl, :weapon => ["Attack"]})
      @bosses.push({:name => "Euron Greyboy", :desc => "Guards the bridge.", :hp => calc_boss_hp, :lvl => @max_lvl, :weapon => ["Bridge Shake"]})
    end

    def calc_stats(capns)
      hp = 0
      max_hp = 0
      max_lvl = 0
      capns.each do |id, capn|
        hp += capn.inv.ilvl
        if capn.inv.ilvl > max_hp
          max_hp = capn.inv.ilvl
        end
        if capn.level > @max_level
          max_lvl = capn.level
        end
      end
      @avg_hp  = hp
      @max_hp  = hp * capns.count
      @max_lvl = max_lvl + DoubloonScape::BOSS_LVL_MODIFIER
    end

    def calc_boss_hp
      avg = (@avg_hp * DoubloonScape::BOSS_HP_MODIFIER).floor.to_i
      max = (@max_hp * DoubloonScape::BOSS_HP_MODIFIER).floor.to_i
      rand(avg..max)
    end

    def do_turn
      events = {}

      if @bosses.empty?
        #raiders win
        @status = :won
        events[:status => :won]
      elsif @raiders.empty?
        #bosses win
        @status = :lost
        events[:status => :lost]
      else
        #load a new boss if there isn't one
        if @current_boss.nil?
          @current_boss = @bosses.sample
        end
        events[:current_boss] = @current_boss.name
        events[:attacks] = Array.new
        events[:dead_raiders] = Array.new

        i=0
        while i < DoubloonScape::RAID_BOSS_ATTACKS
          #boss picks a random person to attack
          target = @raiders.sample
          index = @raiders.index(target)

          attack = rand(target.hp * (DoubloonScape::RAID_BOSS_DAMAGE/100)).floor.to_i
          @raiders[index].hp = target.hp - attack
          events[:attacks].push({:attacker => @current_boss.name, :defender => target.name, :damage => attack, :weapon => @current_boss.weapon.sample})
          if @raiders[index].hp < 1
            events[:dead_raiders].push(@raiders[index].name)
            @raiders.delete[index]
          end
          i+=1
        end

        index = @bosses.index(current_boss)
        @raiders.each do |raider|
          unless @bosses[index].hp < 1
            crit = false
            roll = rand(@bosses[index].lvl)
            if roll > raider.lvl
              attack = 0
            elsif roll >= (raider.lvl * ((100-DoubloonScape::CRIT_STRIKE_CHANCE)/100)).floor.to_i
              crit = true
              attack = (raider.damage * (DoubloonScape::CRIT_STRIKE_DAMAGE/100)).floor.to_i
            else
              attack = rand(raider.damage)
            end
            @bosses[index].hp = @bosses[index].hp - 0
            events[:attacks].push({:attacker => raider.name, :defender => @bosses[index].name, :damage => attack, :crit => crit})
            if @bosses[index].hp < 1
              events[:current_boss_hp] = @bosses[index].hp
              @current_boss = nil
              @bosses.delete[index]
            end
          end
        end
      end

      return events
    end
  end
end

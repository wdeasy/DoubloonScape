module DoubloonScape
  class Raid
    attr_reader :current_boss, :raiders

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
	  	def initialize(id, name, hp, lvl, weapon, damage)
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
        @raiders.push({:id => capn.id, :name => capn.landlubber_name, :hp => capn.inv.ilvl, :current_hp => capn.inv.ilvl, :lvl => capn.level, :weapon => capn.inv.inventory['Main Hand'].name, :damage => capns[id].inv.inventory['Main Hand'].ilvl})
      end
    end

    def load_bosses
      #load bosses to pick from
      #edit - for now raids will start with one boss. can add more if too ez.
      bosses = Array.new
      bosses.push({:name => "Komuz, The Fretless Luter", :desc => "A low-strung bard", :hp => calc_boss_hp, :current_hp => 0,:lvl => @max_lvl, :weapon => ["Healing Tune","Chords of Discord"]})
      bosses.push({:name => "Pippy Darkfin", :desc => "Fearlessly charges you.", :hp => calc_boss_hp, :current_hp => 0, :lvl => @max_lvl, :weapon => ["Narwhal Tusk","Serpent Fang"]})
      bosses.push({:name => "Pee-Wee Merman", :desc => "A loner, a rebel.", :hp => calc_boss_hp, :current_hp => 0, :lvl => @max_lvl, :weapon => ["Tequila Bottle","Red Boat-Eye"]})
      bosses.push({:name => "Euron Greyboy", :desc => "Guards the bridge.", :hp => calc_boss_hp, :current_hp => 0, :lvl => @max_lvl, :weapon => ["Bridge Shake","Bum Finger"]})

      bosses.each do |boss|
        boss[:current_hp] = boss[:hp]
      end
      i=0
      while i < DoubloonScape::RAID_BOSS_NUMBER
        @bosses.push(bosses.sample)
        i+=1
      end
      @current_boss = @bosses.sample
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
        if capn.level > max_lvl
          max_lvl = capn.level
        end
      end
      @avg_hp  = hp
      @max_hp  = hp * capns.count
      @max_lvl = DoubloonScape::MAX_LEVEL + DoubloonScape::BOSS_LVL_MODIFIER
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
        events[:status] = :won
      elsif @raiders.empty?
        #bosses win
        @status = :lost
        events[:status] = :lost
      else
        #load a new boss if there isn't one
        if @current_boss.nil?
          @current_boss = @bosses.sample
        end

        @status = :in_progress
        events[:status] = :in_progress

        events[:current_boss] = @current_boss[:name]
        events[:attacks] = Array.new
        events[:raiders] = Array.new
        events[:dead_raiders] = Array.new

        i=0
        while i < DoubloonScape::RAID_BOSS_ATTACKS
          #boss picks a random person to attack
          target = @raiders.sample
          index = @raiders.index(target)

          attack = rand((target[:hp] * (DoubloonScape::RAID_BOSS_DAMAGE/100)).ceil.to_i)
          @raiders[index][:current_hp] -= attack
          events[:attacks].push({:attacker => @current_boss[:name], :defender => target[:name], :damage => attack, :weapon => @current_boss[:weapon].sample})
          if @raiders[index][:current_hp] < 1
            events[:dead_raiders].push(@raiders[index][:name])
            @raiders.delete(@raiders[index])
          end
          i+=1
        end

        index = @bosses.index(@current_boss)
        events[:current_boss_hp] = @bosses[index][:current_hp]
        @raiders.each do |raider|
          events[:raiders].push(raider)
          unless @bosses[index][:current_hp] < 1
            crit = false
            roll = rand(@bosses[index][:lvl])
            if roll > raider[:lvl]
              attack = 0
            elsif roll >= (raider[:lvl] * ((100-DoubloonScape::CRIT_STRIKE_CHANCE)/100)).floor.to_i
              crit = true
              attack = (raider[:damage] * (DoubloonScape::CRIT_STRIKE_DAMAGE/100)).floor.to_i
            else
              attack = rand(raider[:damage])
            end
            @bosses[index][:current_hp] -= attack
            events[:current_boss_hp] = @bosses[index][:current_hp]
            events[:attacks].push({:attacker => raider[:name], :defender => @bosses[index][:name], :weapon => raider[:weapon], :damage => attack, :crit => crit})
            if @bosses[index][:current_hp] < 1
              @current_boss = nil
              @bosses.delete(@bosses[index])
            end
          end
        end
      end

      return events
    end
  end
end

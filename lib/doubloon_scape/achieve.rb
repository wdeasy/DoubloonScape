module DoubloonScape
  class Achieve
    class Property
      attr_accessor :value
      attr_reader :activation, :initial_value, :tag
      def initialize(name, initial_value, activation, activation_value, tag)
        @name = name
        @value = 0
        @activation = activation
        @activation_value = activation_value
        @initial_value = initial_value
        @tag = tag
      end

      def is_active
        active = false
        case @activation
        when Achieve::ACTIVE_IF_GREATER_THAN
          active = @value > @activation_value
        when Achieve::ACTIVE_IF_LESS_THAN
          active = @value < @activation_value
        when Achieve::ACTIVE_IF_EQUALS_TO
          active = @value == @activation_value
        end
        return active
      end
    end

    class Achievement
      attr_accessor :realm_first
      attr_reader :name, :description, :properties, :unlocked, :realm_first_eligible, :time
      def initialize(name, description, properties, realm_first_eligible)
        @name = name
        @description = description
        @properties = properties
        @unlocked = false
        @realm_first_eligible = realm_first_eligible
        @realm_first = false
        @time = nil
      end

      def display_name
        if @realm_first == true
          "[REALM FIRST] #{@name}"
        else
          @name
        end
      end

      def unlock
        @time = Time.now
        @unlocked = true
      end
    end

    attr_reader :achievements

    ACTIVE_IF_GREATER_THAN = ">"
    ACTIVE_IF_LESS_THAN = "<"
    ACTIVE_IF_EQUALS_TO = "=="

    @@realm_firsts = Array.new

    def initialize
      @properties = Hash.new
      @achievements = Hash.new

      load_properties
      load_achievements
    end

    def define_property(name, initial_value, activation, value, tag)
      @properties[name] = Property.new(name, initial_value, activation, value, tag)
    end

    def define_achievement(name, description, properties, realm_first_eligible)
      @achievements[name] = Achievement.new(name, description, properties, realm_first_eligible)
    end

    def get_value(prop)
      return @properties[prop].value
    end

    def get_initial_value(prop)
      return @properties[prop].initial_value
    end

    def set_value(prop, value)
      case @properties[prop].activation
      when ACTIVE_IF_GREATER_THAN
        value = value > @properties[prop].value ? value : @properties[prop].value
      when ACTIVE_IF_LESS_THAN
        value = value < @properties[prop].value ? value : @properties[prop].value
      end
      @properties[prop].value = value
    end

    def set_values(tag, value)
      @properties.each do |name, prop|
        if prop.tag == tag
          case @properties[name].activation
          when ACTIVE_IF_GREATER_THAN
            value = value > @properties[name].value ? value : @properties[name].value
          when ACTIVE_IF_LESS_THAN
            value = value < @properties[name].value ? value : @properties[name].value
          end
          @properties[name].value = value
        end
      end
    end

    def add_value(tag, value)
      @properties.each do |name, prop|
        if prop.tag == tag
          set_value(name, get_value(name) + value)
        end
      end
    end

    def remove_value(tag, value)
      @properties.each do |name, prop|
        if prop.tag == tag
          set_value(name, get_value(name) - value)
        end
      end
    end

    def reset_value(tag)
      @properties.each do |name, prop|
        if prop.tag == tag
          set_value(name, get_initial_value(name))
        end
      end
    end

    def realm_first_check(achievement)
      if achievement.realm_first_eligible == true && !(@@realm_firsts.include? achievement.name)
        achievement.realm_first = true
        @@realm_firsts.push(achievement.name)
      end
    end

    def load_realm_firsts
      unless @achievements.empty?
        @achievements.each do |name, ach|
          if ach.realm_first == true && !(@@realm_firsts.include? ach.name)
            @@realm_firsts.push(ach.name)
          end
        end
      end
    end

    def check_achievements
      achieved = Hash.new

      @achievements.each do |name, ach|
        if ach.unlocked == false
          active_properties = 0

          ach.properties.each do |prop|
            if @properties[prop].is_active
              active_properties += 1
            end
          end

          if active_properties == ach.properties.length
            ach.unlock
            realm_first_check(ach)
            achieved[ach.display_name] = ach.description
          end
        end
      end
      return achieved
    end

    def count
      count = 0
      @achievements.each do |name, ach|
        if ach.unlocked == true
          count += 1
        end
      end
      return count
    end

    def total
      @achievements.count
    end

    def load_properties
      #for the alphas
      define_property('alpha', 0, ACTIVE_IF_GREATER_THAN, 0, 'alpha')
      define_property('firstplace', 0, ACTIVE_IF_GREATER_THAN, 0, 'firstplace')

      #captains taken
      define_property('count1', 0, ACTIVE_IF_GREATER_THAN, 0, 'counts')
      define_property('count5', 0, ACTIVE_IF_GREATER_THAN, 4, 'counts')
      define_property('count10', 0, ACTIVE_IF_GREATER_THAN, 9, 'counts')
      define_property('count25', 0, ACTIVE_IF_GREATER_THAN, 24, 'counts')
      define_property('count50', 0, ACTIVE_IF_GREATER_THAN, 49, 'counts')
      define_property('count100', 0, ACTIVE_IF_GREATER_THAN, 99, 'counts')
      define_property('count250', 0, ACTIVE_IF_GREATER_THAN, 249, 'counts')
      define_property('count500', 0, ACTIVE_IF_GREATER_THAN, 499, 'counts')
      define_property('count1000', 0, ACTIVE_IF_GREATER_THAN, 999, 'counts')

      #current time
      define_property('current1', 0, ACTIVE_IF_GREATER_THAN, 60*60, 'currents')
      define_property('current3', 0, ACTIVE_IF_GREATER_THAN, 60*60*3, 'currents')
      define_property('current6', 0, ACTIVE_IF_GREATER_THAN, 60*60*6, 'currents')
      define_property('current12', 0, ACTIVE_IF_GREATER_THAN, 60*60*12, 'currents')
      define_property('current24', 0, ACTIVE_IF_GREATER_THAN, 60*60*24, 'currents')

      #total time
      define_property('totalh', 0, ACTIVE_IF_GREATER_THAN, 60*60, 'totals')
      define_property('totald', 0, ACTIVE_IF_GREATER_THAN, 60*60*24, 'totals')
      define_property('totalw', 0, ACTIVE_IF_GREATER_THAN, 60*60*24*7, 'totals')
      define_property('totalm', 0, ACTIVE_IF_GREATER_THAN, 60*60*24*31, 'totals')
      define_property('totaly', 0, ACTIVE_IF_GREATER_THAN, 60*60*24*365, 'totals')

      #levels
      define_property('level10', 1, ACTIVE_IF_GREATER_THAN, 9, 'levels')
      define_property('level20', 1, ACTIVE_IF_GREATER_THAN, 19, 'levels')
      define_property('level30', 1, ACTIVE_IF_GREATER_THAN, 29, 'levels')
      define_property('level40', 1, ACTIVE_IF_GREATER_THAN, 39, 'levels')
      define_property('level50', 1, ACTIVE_IF_GREATER_THAN, 49, 'levels')
      define_property('level60', 1, ACTIVE_IF_GREATER_THAN, 59, 'levels')

      #current gold
      define_property('gold100', 0, ACTIVE_IF_GREATER_THAN, 99, 'gold')
      define_property('gold1000', 0, ACTIVE_IF_GREATER_THAN, 999, 'gold')
      define_property('gold10000', 0, ACTIVE_IF_GREATER_THAN, 9999, 'gold')
      define_property('gold100000', 0, ACTIVE_IF_GREATER_THAN, 99999, 'gold')
      define_property('gold1000000', 0, ACTIVE_IF_GREATER_THAN, 999999, 'gold')

      #captains per hour
      define_property('10hour', 0, ACTIVE_IF_GREATER_THAN, 9, 'rates')
      define_property('20hour', 0, ACTIVE_IF_GREATER_THAN, 19, 'rates')
      define_property('30hour', 0, ACTIVE_IF_GREATER_THAN, 29, 'rates')
      define_property('40hour', 0, ACTIVE_IF_GREATER_THAN, 39, 'rates')

      #deserter
      define_property('deserter1', 0, ACTIVE_IF_GREATER_THAN, 0, 'deserter')
      define_property('deserter5', 0, ACTIVE_IF_GREATER_THAN, 4, 'deserter')
      define_property('deserter25', 0, ACTIVE_IF_GREATER_THAN, 24, 'deserter')

      #denied
      define_property('denier1', 0, ACTIVE_IF_GREATER_THAN, 0, 'denies')
      define_property('denier5', 0, ACTIVE_IF_GREATER_THAN, 4, 'denies')
      define_property('denier25', 0, ACTIVE_IF_GREATER_THAN, 24, 'denies')

      #events
      define_property('bermuda', 0, ACTIVE_IF_GREATER_THAN, 0, 'bermuda')
      define_property('atlantis', 0, ACTIVE_IF_GREATER_THAN, 0, 'atlantis')
      define_property('atlamuda', 0, ACTIVE_IF_GREATER_THAN, 0, 'atlamuda')

      #necro
      define_property('necro1', 0, ACTIVE_IF_GREATER_THAN, 0, 'necro')
      define_property('necro5', 0, ACTIVE_IF_GREATER_THAN, 4, 'necro')
      define_property('necro25', 0, ACTIVE_IF_GREATER_THAN, 24, 'necro')

      #time of day
      define_property('midnight', 0, ACTIVE_IF_GREATER_THAN, 0, 'midnight')
      define_property('dusk', 0, ACTIVE_IF_GREATER_THAN, 0, 'dusk')
      define_property('dawn', 0, ACTIVE_IF_GREATER_THAN, 0, 'dawn')
      define_property('noon', 0, ACTIVE_IF_GREATER_THAN, 0, 'noon')
      define_property('latenight', 0, ACTIVE_IF_GREATER_THAN, 0, 'latenight')
      define_property('earlymorning', 0, ACTIVE_IF_GREATER_THAN, 0, 'earlymorning')

      #items
      define_property('unique1', 0, ACTIVE_IF_GREATER_THAN, 0, 'uniques')
      define_property('unique5', 0, ACTIVE_IF_GREATER_THAN, 4, 'uniques')
      define_property('unique25', 0, ACTIVE_IF_GREATER_THAN, 24, 'uniques')
      define_property('pegleg', 0, ACTIVE_IF_GREATER_THAN, 0, 'pegleg')
      define_property('rune', 0, ACTIVE_IF_GREATER_THAN, 0, 'rune')

      #nemesis
      define_property('nemesis5', 0, ACTIVE_IF_GREATER_THAN, 0, 'nemesis5')
      define_property('nemesis10', 0, ACTIVE_IF_GREATER_THAN, 0, 'nemesis10')
      define_property('nemesis25', 0, ACTIVE_IF_GREATER_THAN, 0, 'nemesis25')

      #1v1
      define_property('challenger5', 0, ACTIVE_IF_GREATER_THAN, 0, 'challenger5')
      define_property('challenger10', 0, ACTIVE_IF_GREATER_THAN, 0, 'challenger10')
      define_property('challenger25', 0, ACTIVE_IF_GREATER_THAN, 0, 'challenger25')

      #mutines
      define_property('mutiny1', 0, ACTIVE_IF_GREATER_THAN, 0, 'mutiny')
      define_property('mutiny5', 0, ACTIVE_IF_GREATER_THAN, 4, 'mutiny')
      define_property('mutiny25', 0, ACTIVE_IF_GREATER_THAN, 24, 'mutiny')

      #duels
      define_property('duel1', 0, ACTIVE_IF_GREATER_THAN, 0, 'duel')
      define_property('duel5', 0, ACTIVE_IF_GREATER_THAN, 4, 'duel')
      define_property('duel25', 0, ACTIVE_IF_GREATER_THAN, 24, 'duel')

      #treasure
      define_property('treasure1', 0, ACTIVE_IF_GREATER_THAN, 0, 'treasures')
      define_property('treasure5', 0, ACTIVE_IF_GREATER_THAN, 4, 'treasures')
      define_property('treasure25', 0, ACTIVE_IF_GREATER_THAN, 24, 'treasures')

      #enemies
      define_property('kraken', 0, ACTIVE_IF_GREATER_THAN, 0, 'The Kraken')
      define_property('mobydick', 0, ACTIVE_IF_GREATER_THAN, 0, 'Moby Dick')
      define_property('leviathan', 0, ACTIVE_IF_GREATER_THAN, 0, 'The Leviathan')
      define_property('hydra', 0, ACTIVE_IF_GREATER_THAN, 0, 'A Hydra')
      define_property('queen', 0, ACTIVE_IF_GREATER_THAN, 0, 'The Queen Anne\'s Revenge')
      define_property('nelson', 0, ACTIVE_IF_GREATER_THAN, 0, 'Admiral Nelson')

      #ilvl
      define_property('ilvl100', 0, ACTIVE_IF_GREATER_THAN, 99, 'ilvl')
      define_property('ilvl250', 0, ACTIVE_IF_GREATER_THAN, 249, 'ilvl')
      define_property('ilvl500', 0, ACTIVE_IF_GREATER_THAN, 499, 'ilvl')
      define_property('ilvl1000', 0, ACTIVE_IF_GREATER_THAN, 999, 'ilvl')
      define_property('ilvl2500', 0, ACTIVE_IF_GREATER_THAN, 2499, 'ilvl')
    end

    def load_achievements
      define_achievement("I WAS THE CAPTAIN THEN", "Played the Original DoubloonScape.", ['alpha'], false)
      define_achievement("TERROR OF THE SEAS", "Ranked #1 in a Previous Season.", ['firstplace'], false)

      #captains taken
      define_achievement("YOU ARE A PIRATE", "Take the Captain.", ['count1'], true)
      define_achievement("COMMAND", "Take the Captain 5 times.", ['count5'], true)
      define_achievement("CONQUER", "Take the Captain 10 times.", ['count10'], true)
      define_achievement("MASTERY", "Take the Captain 25 times.", ['count25'], true)
      define_achievement("SOVEREIGN", "Take the Captain 50 times.", ['count50'], true)
      define_achievement("SUPREMACY", "Take the Captain 100 times.", ['count100'], true)
      define_achievement("ASCENDANCY", "Take the Captain 250 times.", ['count250'], true)
      define_achievement("DOMINION", "Take the Captain 500 times.", ['count500'], true)
      define_achievement("MAN O' WAR", "Take the Captain 1000 times.", ['count1000'], true)

      #current time
      define_achievement("BUCKLE DOWN", "Hold the Captain for 1 hour", ['current1'], true)
      define_achievement("PEG AWAY", "Hold the Captain for 3 hours", ['current3'], true)
      define_achievement("DRUDGE", "Hold the Captain for 6 hours", ['current6'], true)
      define_achievement("MANIFEST", "Hold the Captain for 12 hours", ['current12'], true)
      define_achievement("KING OF THE HILL", "Hold the Captain for 24 hours", ['current24'], true)

      #total time
      define_achievement("TIDE", "Have Over 1 Hour of Total Captain Time.", ['totalh'], true)
      define_achievement("TOUR", "Have Over 1 Day of Total Captain Time.", ['totald'], true)
      define_achievement("SPAN", "Have Over 1 Week of Total Captain Time.", ['totalw'], true)
      define_achievement("EPOCH", "Have Over 1 Month of Total Captain Time.", ['totalm'], true)
      define_achievement("ETERNITY", "Have Over 1 Year of Total Captain Time.", ['totaly'], true)

      #levels
      define_achievement("DECKHAND", "Reach level 10.", ['level10'], true)
      define_achievement("SWASHBUCKLER", "Reach level 20.", ['level20'], true)
      define_achievement("BUCCANEER", "Reach level 30.", ['level30'], true)
      define_achievement("CORSAIR", "Reach level 40.", ['level40'], true)
      define_achievement("FIRST MATE", "Reach level 50.", ['level50'], true)
      define_achievement("SCOURGE OF THE SEVEN SEAS", "Reach level 60.", ['level60'], true)

      #current gold
      define_achievement("MODEST", "Have 100 gold.", ['gold100'], true)
      define_achievement("TANGIBLE", "Have 1,000 gold.", ['gold1000'], true)
      define_achievement("AFFLUENT", "Have 10,000 gold.", ['gold10000'], true)
      define_achievement("GILDED", "Have 100,000 gold.", ['gold100000'], true)
      define_achievement("AVARICE", "Have 1,000,000 gold.", ['gold1000000'], true)

      #captains per hour
      define_achievement("STUBBORN", "Take the Captain 10 times in under an hour.", ['10hour'], true)
      define_achievement("INSISTENT", "Take the Captain 20 times in under an hour.", ['20hour'], true)
      define_achievement("RELENTLESS", "Take the Captain 30 times in under an hour.", ['30hour'], true)
      define_achievement("TIME TRAVELER", "Take the Captain 40 times in under an hour.", ['40hour'], true)

      #deserter
      define_achievement("MAROONED", "Go offline as Captain.", ['deserter1'], true)
      define_achievement("DESERTER", "Go offline as Captain 5 times.", ['deserter5'], true)
      define_achievement("ABANDONEER", "Go offline as Captain 25 times.", ['deserter25'], true)

      #denies
      define_achievement("DENIED", "Steal the Captain from someone who is about to level.", ['denier1'], true)
      define_achievement("RUDE", "Steal the Captain from someone who is about to level 5 times.", ['denier5'], true)
      define_achievement("BAMBOOZLED", "Steal the Captain from someone who is about to level 25 times.", ['denier25'], true)

      #events
      define_achievement("ATLANTIS", "Discover Atlantis.", ['atlantis'], true)
      define_achievement("BERMUDA TRIANGLE", "Get lost in the Bermuda Triangle.", ['bermuda'], true)
      define_achievement("THE PERFECT STORM", "Find Atlantis and the Bermuda Triangle at the same time.", ['atlamuda'], true)

      #necro
      define_achievement("AWAKEN", "Steal the Captain from an offline player.", ['necro1'], true)
      define_achievement("REDEEMER", "Steal the Captain from an offline player 5 times.", ['necro5'], true)
      define_achievement("NECROMANCER", "Steal the Captain from an offline player 25 times.", ['necro25'], true)

      #time of day
      define_achievement("MIDNIGHT CAPTAIN", "Take the captain at Midnight.", ['midnight'], true)
      define_achievement("RED SKY AT NIGHT", "Take the captain at Dusk.", ['dusk'], true)
      define_achievement("RED SKY AT MORNING", "Take the captain at Dawn.", ['dawn'], true)
      define_achievement("NOONER SCHOONER", "Take the captain at Noon.", ['noon'], true)
      define_achievement("EARLY BIRD", "Take the captain early in the morning.", ['latenight'], true)
      define_achievement("NIGHT OWL", "Take the captain late at night.", ['earlymorning'], true)

      #items
      define_achievement("SCAVENGER", "Find a Unique Item.", ['unique1'], true)
      define_achievement("COLLECTOR", "Find 5 Unique Items.", ['unique5'], true)
      define_achievement("HOARDER", "Find 25 Unique Items.", ['unique25'], true)
      define_achievement("NAVAL NEGAN", "Find the Barnacle-Covered Pegleg.", ['pegleg'], true)
      define_achievement("RUN ESCAPE", "Find Rune\'s Cape.", ['rune'], true)

      #nemesis
      define_achievement("ADVERSARY", "Have 5 out of the past 10 Captains Taken.", ['nemesis5'], true)
      define_achievement("AVENGER", "Have 10 out of the past 20 Captains Taken.", ['nemesis10'], true)
      define_achievement("NEMESIS", "Have 25 out of the past 50 Captains Taken.", ['nemesis25'], true)

      #challenger
      define_achievement("STAND YOUR GROUND", "Retake the Captain 5 times in a Row.", ['challenger5'], true)
      define_achievement("CHALLENGER", "Retake the Captain 10 times in a Row.", ['challenger10'], true)
      define_achievement("RELENTLESS", "Retake the Captain 25 times in a Row.", ['challenger25'], true)

      #mutinies
      define_achievement("LOATHED", "Hold off a Mutiny", ['mutiny1'], true)
      define_achievement("DETESTED", "Hold off 5 Mutines", ['mutiny5'], true)
      define_achievement("UNDESIRABLE", "Hold off 25 Mutinies", ['mutiny25'], true)

      #duels
      define_achievement("VICTOR", "Win a duel while taking Captain", ['duel1'], true)
      define_achievement("TRIUMPH", "Win a duel while taking Captain 5 times.", ['duel5'], true)
      define_achievement("CONQUEST", "Win a duel while taking Captain 25 times.", ['duel25'], true)

      #treasure
      define_achievement("LUCKY", "Loot the Treasure Chest.", ['treasure1'], true)
      define_achievement("FORTUNATE", "Loot the Treasure Chest 5 times.", ['treasure5'], true)
      define_achievement("COINCIDENCE", "Loot the Treasure Chest 25 times.", ['treasure25'], true)

      #enemies
      define_achievement("GIANT SQUID", "Defeat The Kraken.", ['kraken'], true)
      define_achievement("WHALE OF A TALE", "Defeat Moby Dick.", ['mobydick'], true)
      define_achievement("BEHEMOTH", "Defeat The Leviathan.", ['leviathan'], true)
      define_achievement("MANY-HEADED MENACE", "Defeat The Hydra.", ['hydra'], true)
      define_achievement("BLACKBEARD", "Defeat Queen Anne\'s Revenge.", ['queen'], true)
      define_achievement("THE DREADED REAR ADMIRAL", "Defeat Admiral Nelson.", ['nelson'], true)
      define_achievement("VANQUISHER", "Defeat all enemies at sea.", ['kraken','mobydick','leviathan','hydra','queen','nelson'], true)

      #uncomment next season, will break current season
      #ilvl
      define_achievement("CLAD", "Have an iLVL over 100.", ['ilvl100'], true)
      define_achievement("ARMED", "Have an iLVL over 250.", ['ilvl250'], true)
      define_achievement("SUITED", "Have an iLVL over 500.", ['ilvl500'], true)
      define_achievement("ADORNED", "Have an iLVL over 1000.", ['ilvl1000'], true)
      define_achievement("BEDECKED", "Have an iLVL over 2500.", ['ilvl2500'], true)
    end
  end
end

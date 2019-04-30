module DoubloonScape
  class Raid
    def initialize(capns)
      @bosses = Array.new
      @captains = Array.new

      load_bosses
      load_captains
    end

    def load_captains(capns)
      #loop through captains and create an object to track their health
      #health is equal to their ilvl
    end

    def load_bosses
      #load bosses to pick from
      @bosses.push({:name => "Komuz, The Fretless Luter", :desc => "A low-strung bard", :hp => "1000", :attack => "Healing Tune"})
    end

    def do_turn
      #if boss is at zero health, win
      #winning battle should get xp and guaranteed loot
      #if all captains are at zero health, lose

      #boss chooses random captain to attack
      #roll to see if attack succeeds (should have high probability)
      #subtract damage from health (ilvl) if successful

      #loop through each captain who is above 0 health
      #roll to see if attack succeeds
      #subtract health from boss
    end
  end
end

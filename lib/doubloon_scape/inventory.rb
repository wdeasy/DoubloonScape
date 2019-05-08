require 'date'

module DoubloonScape
	class Inventory
		class Item
			attr_reader :ilvl, :name, :description
	  	def initialize(ilvl, slot, name, description)
	  		@ilvl = ilvl
	  		@slot = slot
	  		@name = name
	  		@description = description
	  	end
	  end
	  ### end of item class

	  def initialize
	  	@common = Hash.new
	  	@unique = Array.new
	  	@inventory = Hash.new

	  	load_commons
	  	load_uniques
	  	load_inventory
		end

	  def inventory
	  	@inventory
	  end

	  def load_inventory
	    head     = Item.new(1,'Head',      @common['Head'][:names].sample,      @common['Head'][:description])
	  	chest    = Item.new(1,'Chest',     @common['Chest'][:names].sample,     @common['Chest'][:description])
	  	hands    = Item.new(1,'Hands',     @common['Hands'][:names].sample,     @common['Hands'][:description])
	  	legs     = Item.new(1,'Legs',      @common['Legs'][:names].sample,      @common['Legs'][:description])
	  	pet      = Item.new(1,'Pet',       @common['Pet'][:names].sample,       @common['Pet'][:description])
	  	trinket  = Item.new(1,'Trinket',   @common['Trinket'][:names].sample,   @common['Trinket'][:description])
	  	mainhand = Item.new(1,'Main Hand', @common['Main Hand'][:names].sample, @common['Main Hand'][:description])
	  	offhand  = Item.new(1,'Off Hand',  @common['Off Hand'][:names].sample,  @common['Off Hand'][:description])

	  	@inventory['Head']      = head
	  	@inventory['Chest']     = chest
	  	@inventory['Hands']     = hands
	  	@inventory['Legs']      = legs
	  	@inventory['Pet']       = pet
	  	@inventory['Trinket']   = trinket
	  	@inventory['Main Hand'] = mainhand
	  	@inventory['Off Hand']  = offhand
	  end

	  def load_commons
	  	@common['Head']       = {:names => ['Tricorne', 'Monmouth Cap'],     :description=> 'A Common Item.'}
	  	@common['Chest']      = {:names => ['Doublet','Waistcoat'],          :description=> 'A Common Item.'}
	  	@common['Hands']      = {:names => ['Hook', 'Leather Gloves'],       :description=> 'A Common Item.'}
	  	@common['Legs']       = {:names => ['Pegleg','Breeches'],            :description=> 'A Common Item.'}
	  	@common['Pet']        = {:names => ['Parrot','Squid'],               :description=> 'A Common Pet.'}
	  	@common['Trinket']    = {:names => ['Compass','Pocketwatch'],        :description=> 'A Common Item.'}
	  	@common['Main Hand']  = {:names => ['Blunderbuss','Cutlass'],        :description=> 'A Common Item.'}
	  	@common['Off Hand']   = {:names => ['Lantern','Stein','Cannonball'], :description=> 'A Common Item.'}
	  end

	  def load_uniques
	  	#10
	  	@unique.push({:level => 10, :slot => 'Main Hand', :name => "Swordfish",               :description => "Pretty Straightforward."})
	  	@unique.push({:level => 10, :slot => 'Legs',      :name => "Salty Pantaloons",        :description => "Most Uncomfortable."})
      @unique.push({:level => 10, :slot => 'Pet',       :name => "Fish out of Water",       :description => "Flops around your feet. You could help it, but meh."})

	  	#20
	  	@unique.push({:level => 20, :slot => 'Main Hand', :name => "Rusty Pitchfork",         :description => "I guess *technically* it's a Trident..."})
	  	@unique.push({:level => 20, :slot => 'Off Hand',  :name => "Discarded Ship Wheel",    :description => "It's the thought that counts."})
	  	@unique.push({:level => 20, :slot => 'Chest',     :name => "Chromatic Rags",          :description => "Grant you 1 armor and 1000 all resist."})

	  	#30
	  	@unique.push({:level => 30, :slot => 'Main Hand', :name => "Seaweed Whip",            :description => "All out of tentacle whips. This'll have to do."})
	  	@unique.push({:level => 30, :slot => 'Trinket',   :name => "Empowering 'I Refuse to Sink' Anchor Tattoo", :description => "The irony is lost on you."})
	  	@unique.push({:level => 30, :slot => 'Chest',     :name => "Leathers of the Father",  :description => "Dad likes leather!"})

	  	#40
	  	@unique.push({:level => 40, :slot => 'Hands',     :name => "Algae Fists",             :description => "Seemed like a good idea at the time."})
	  	@unique.push({:level => 40, :slot => 'Pet',       :name => "Powder Monkey",           :description => "An Albino Capuchin."})
	  	@unique.push({:level => 40, :slot => 'Trinket',   :name => "Pocket Submarine",        :description => "Clutch!"})

	  	#50
	  	@unique.push({:level => 50, :slot => 'Pet',       :name => "Indebted Octopus",        :description => "You spared his life and now he owes you a favor."})
	  	@unique.push({:level => 50, :slot => 'Trinket',   :name => "The Nautilus",            :description => "This mollusk always points north!"})

	  	#60
	  	@unique.push({:level => 60, :slot => 'Main Hand', :name => "Barnacle-Covered Pegleg", :description => "Her name's Lucille."})
	  	@unique.push({:level => 60, :slot => 'chest',     :name => "Rune\'s Cape",            :description => "Pilfered from a Swedish Nobleman."})

	  end

	  def item_check(level, tailwind=1)
	  	item = {}

			multiplier = 1
			if Date.parse(DoubloonScape::PIRATES_DAY) == Date.today
				multiplier = DoubloonScape::PIRATES_DAY_MULTIPLIER
			end

	  	if rand(100/multiplier) < (DoubloonScape::ITEM_CHANCE * tailwind)
	  		ilvl = rand(1..(level * DoubloonScape::ITEM_LEVEL)).floor.to_i
	  		slot = ['Head', 'Chest', 'Hands', 'Legs', 'Pet', 'Trinket', 'Main Hand', 'Off Hand'].sample

				item_name = @common[slot][:names].sample
				item_qlty = :common
				item_desc = nil

				if rand(100) < DoubloonScape::UNIQUE_ITEM_CHANCE
					unique = @unique.reject {|x| x[:slot] != slot }
					unique.reject! {|x| level < x[:level]}
					unique_item = unique.sample
					unless unique_item.nil?
						item_name = unique_item[:name]
						item_qlty = :unique
						item_desc = unique_item[:description]
					end
				end

				if ilvl > inventory[slot].ilvl
					@inventory[slot] = Item.new(ilvl, slot, item_name, item_desc)
					item = {:quality => item_qlty, :name => item_name, :description => item_desc, :ilvl => ilvl, :better => true}
				else
					item = {:quality => item_qlty, :name => item_name, :description => item_desc, :ilvl => ilvl, :better => false}
	  		end
	  	end
	  	return item
	  end

	  def ilvl
	  	ilvl = 0
	  	@inventory.each do |key, val|
	  		ilvl += val.ilvl
	  	end
	  	return ilvl
	  end

	  def battle_item(battle)
	  	case battle[:enemy]
	  	when 'Admiral Nelson'
	  		battle[:item_name] = 'Nelson\'s Folly'
				battle[:item_description] = 'Stolen from the Dreaded Rear Admiral himself.'
	  		@inventory['Off Hand'] = Item.new(rand(200..300), 'Off Hand', battle[:item_name], battle[:item_description])
	  	when 'The Kraken'
	  		battle[:item_name] = 'Tentacle Whip'
				battle[:item_description] = 'Fashioned from a dismembered Kraken limb.'
	  		@inventory['Main Hand'] = Item.new(rand(200..300), 'Main Hand', battle[:item_name], battle[:item_description])
	  	end
	  	return battle
	  end
  end
end

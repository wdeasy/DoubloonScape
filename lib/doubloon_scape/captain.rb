require 'active_support/time'
require 'yaml/store'
require 'date'
require 'time'

module DoubloonScape
  class Captain
    attr_accessor :status, :last_update, :offline, :current, :tailwind, :current_gold, :last_pickpocket
    attr_reader :inv, :next_level, :xp, :id, :achieves, :level, :gold, :count, :locked, :total

    def initialize(id)
      @id = id
      @name = 'The Captain Now'
      @level = 1
      @next_level = calc_level_up
      @xp = 0
      @gold = 0
      @count = 0
      @start_time = nil
      @last_update = Time.now
      @current = 0
      @current_gold = 0
      @total = 0
      @record = 0
      @previous = 0
      @created = Time.now
      @status = nil
      @locked = false
      @history = Array.new(60)
      @offline = 0
      @tailwind = 1
      @last_pickpocket = Time.now - DoubloonScape::PICKPOCKET_COOLDOWN.minutes

      #inventory
      @inv = DoubloonScape::Inventory.new

      #achievements
      @achieves = DoubloonScape::Achieve.new
    end

    def landlubber_name
      @name
    end

    def update_name(name)
      @name = strip_name(name)
    end

    def strip_name(name)
    	if DoubloonScape::EMOJI.any? { |emoji| name.include? emoji }
      	DoubloonScape::EMOJI.each do |e|
      	  name.sub! e, ''
      	end
      end
      return name.strip
    end

    def captain_name
      "#{@name} #{DoubloonScape::EMOJI[0]}"
    end

    def give_gold(amount)
      @gold += amount
      @current_gold += amount
      @achieves.set_values('gold', @gold.floor.to_i)
    end

    def take_gold(amount)
      @gold -= amount
      @current_gold -= amount
      @achieves.set_values('gold', @gold.floor.to_i)
    end

    def give_xp(amount)
      @xp += amount
    end

    def update_current(time)
      @current += time
      @achieves.set_values('currents', @current)
    end

    def update_total(time)
      @total += time
      @achieves.set_values('totals', @total)
    end

    def update_count
      @count += 1
      @achieves.set_values('counts', @count)
    end

    def time_check
      case @start_time.hour
      when 0
        @achieves.add_value('midnight', 1)
      when 12
        @achieves.add_value('noon', 1)
      when 7
        @achieves.add_value('dawn', 1)
      when 19
        @achieves.add_value('dusk', 1)
      when 2..4
        @achieves.add_value('nightowl', 1)
      when 5..6
        @achieves.add_value('earlybird', 1)
      end
    end

    def time_started
      @history.push(Time.now)
      @history.shift

      @start_time = Time.now
      @last_update = Time.now
      @current = 0
      @current_gold = 0
      @offline = 0
      @achieves.reset_value('currents')
      rate_check
      time_check
    end

    def rate_check
      rate = 0
      @history.each do |take|
        unless take.nil?
          if (Time.now - take) < 1.hour
            rate += 1
          end
        end
      end
      @achieves.set_values('rates', rate)
    end

    def base_xp(lvl)
      (DoubloonScape::BASE*(DoubloonScape::MULTIPLIER ** (lvl - 1))).ceil
    end

    def calc_level_up
      if @level > 60
        @next_level = base_xp(@level) + (1440 * (@level - 60))
      else
        @next_level = base_xp(@level)
      end
    end

    def level_check
      if @xp >= @next_level
        @level += 1
        @xp = 0
        @next_level = calc_level_up
        @achieves.set_values('levels', @level)
        return {:name => @name, :level => @level}
      else
        return nil
      end
    end

    def record_check
      if @current > @record && @record != @previous && @record > 59
        @previous = @record
        return {:name => @name, :record => @record}
      else
        return nil
      end
    end

    def update_record
      if @record < @current
        @record = @current
      end
      @current = 0
    end

    def achieve_check
      return @achieves.check_achievements
    end

    def bonus_check
      if @start_time.nil? || !Date.parse(@start_time.to_s).today?
        bonus = (base_xp(@level) * DoubloonScape::BONUS).floor.to_i
        @xp += bonus
        return true
      else
        return nil
      end
    end

    def item_check
      item = @inv.item_check(@level)
      unless item.empty?
        item[:captain] = @name
        if item[:quality] == :unique
          @achieves.add_value('uniques', 1)
          if item[:name] == "Barnacle-Covered Pegleg"
            @achieves.add_value('pegleg', 1)
          end
        end
        @achieves.set_values('ilvl', @inv.ilvl)
      end
      return item
    end

    def roll
      @inv.ilvl
    end

    def record
      if @current > @record
        return @current
      else
        return @record
      end
    end

    def next
      @next_level - @xp
    end

    def update_name(name)
      if strip_name(name) != @name
        @name = strip_name(name)
      end
    end

    def save_record
      if @record < @current
        @record = @current
      end
    end

    #lock the captain during an update to prevent a do_turn / change_captains conflict
    def lock
      @locked = true
    end

    def unlock
      @locked = false
    end
  end
end

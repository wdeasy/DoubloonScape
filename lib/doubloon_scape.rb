require_relative './doubloon_scape/game'
require_relative './doubloon_scape/captain'
require_relative './doubloon_scape/achieve'
require_relative './doubloon_scape/event'
require_relative './doubloon_scape/raid'
require_relative './doubloon_scape/inventory'

module DoubloonScape
  ## game settings
  ################

  #captains save file
  CAPTAINS   = 'data/captains.yaml'

  #emoji
  EMOJI      = ["🔱",":trident:","\u{1F531}"]

  #base time for turns
  SECONDS    = 60

  #base amount of xp and gold given each turn
  AMOUNT     = 1

  #first captain of the day bonus
  BONUS      = 10.0                 #percent

  #level math
  BASE 		   = 10
  MULTIPLIER = 1.1

  #how long to wait before being declared a deserter
  OFFLINE            = 5           #minutes

  #events
  MUTINY_COOLDOWN    = 30          #minutes
  DUEL_COOLDOWN      = 30          #minutes
  MUTINEER_COUNT     = 3           #online players required
  MUTINEER_BONUS     = 5.0         #percent awarded to mutineers if they win
  DUEL_BONUS         = 10.0        #percent

  PICKPOCKET_COOLDOWN = 30         #minutes
  PICKPOCKET_CHANCE  = 1           #percent
  PICKPOCKET_MAX     = 20          #percent
  BATTLE_COOLDOWN    = 30          #minutes
  BATTLE_CHANCE      = 1           #percent
  BATTLE_WIN_AMOUNT  = 10          #percent
  BATTLE_MIN_LEVEL   = 20
  BATTLE_ITEM_CHANCE = 1           #percent

  #atlantis and bermuda triangle
  ATLAMUDA_CHANCE    = 0.5         #percent
  ATLANTIS_MOD_MAX   = 100.0       #percent
  BERMUDA_MOD_MAX    = 50.0        #percent
  BUFF_DURATION      = 60          #minutes

  #items
  ITEM_CHANCE        = 1.0         #percent
  MAX_ITEM_LEVEL     = 5           #x level
  MIN_ITEM_LEVEL     = 5           #- level
  UNIQUE_ITEM_CHANCE = 20.0        #percent
  UNIQUE_ITEM_MAX    = 3.0         #percent
  BETTER_ITEM_CHANCE = 1.4         #percent

  #new captain events
  CONTEST_CHANCE     = 10.0        #percent
  WIN_TIME_ADDED     = 5           #minutes
  BRIG_DURATION      = 5           #minutes

  #jackpot
  TREASURE_CHANCE    = 0.1         #percent

  #tailwind (catchup mechanic)
  TAILWIND_MULTIPLIER = 1

  #high seas (increase contest chance)
  HIGH_SEAS_MULTIPLIER = 2

  #ghost captain (previous offline captain)
  GHOST_CAPTAIN_CHANCE = 25.0      #percent

  #keelhaul
  KEELHAUL_CHANCE = 1

  #pirates day (increased item chance)
  PIRATES_DAY = "September 19"
  PIRATES_DAY_MULTIPLIER = 2

  #whirlpool
  WHIRLPOOL_COOLDOWN      = 1440   #minutes
  WHIRLPOOL_CHANCE        = 0.5    #percent
  WHIRLPOOL_AMOUNT        = 1.0    #percent
  WHIRLPOOL_ESCAPE_CHANCE = 20.0   #percent

  #lootbox
  LOOTBOX_PRICE           = 500    #gold
  LOOTBOX_CHANCE          = 0.5    #percent

  #max level
  MAX_LEVEL               = 60     #level

  #raid
  RAID_COOLDOWN           = 1440   #minutes
  RAID_CHANCE             = 1.0    #percent
  BOSS_HP_MODIFIER        = 0.5    #multiplier
  BOSS_LVL_MODIFIER       = 5      #number
  RAID_BOSS_NUMBER        = 1      #number
  RAID_BOSS_ATTACKS       = 1      #number
  RAID_BOSS_DAMAGE        = 100.0   #percent
  CRIT_STRIKE_CHANCE      = 5.0    #percent
  CRIT_STRIKE_DAMAGE      = 300.0  #percent
  RAID_WIN_LVL_AMOUNT     = 10.0   #percent
  RAID_WIN_GOLD_AMOUNT    = 100.0  #percent
end

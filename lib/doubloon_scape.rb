require_relative './doubloon_scape/game'
require_relative './doubloon_scape/captain'
require_relative './doubloon_scape/achieve'
require_relative './doubloon_scape/event'
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
  BONUS      = 10          #percent

  #level math
  BASE 		   = 10
  MULTIPLIER = 1.1

  #how long to wait before being declared a deserter
  OFFLINE            = 5   #minutes

  #events
  MUTINY_COOLDOWN    = 30  #minutes
  DUEL_COOLDOWN      = 30  #minutes
  MUTINEER_COUNT     = 3   #online players required
  MUTINEER_BONUS     = 5   #percent awarded to mutineers if they win
  DUEL_BONUS         = 10  #percent

  PICKPOCKET_COOLDOWN = 30 #minutes
  PICKPOCKET_CHANCE  = 1   #percent
  PICKPOCKET_MAX     = 20  #percent
  BATTLE_COOLDOWN    = 30  #minutes
  BATTLE_CHANCE      = 1   #percent
  BATTLE_WIN_AMOUNT  = 10  #percent
  BATTLE_MIN_LEVEL   = 20
  BATTLE_ITEM_CHANCE = 1   #percent

  #atlantis and bermuda triangle
  ATLAMUDA_CHANCE    = 0.5 #percent
  ATLANTIS_MOD_MAX   = 100 #percent
  BERMUDA_MOD_MAX    = 50  #percent
  BUFF_DURATION      = 60  #minutes

  #items
  ITEM_CHANCE        = 1   #percent
  ITEM_LEVEL         = 1.5 #percent
  UNIQUE_ITEM_CHANCE = 20  #percent
  UNIQUE_ITEM_MAX    = 3   #percent
  BETTER_ITEM_CHANCE = 1.4 #percent

  #new captain events
  CONTEST_CHANCE     = 10  #percent
  WIN_TIME_ADDED     = 5   #minutes
  BRIG_DURATION      = 5   #minutes

  #jackpot
  TREASURE_CHANCE    = 0.1  #percent

  #tailwind (catchup mechanic)
  TAILWIND_MULTIPLIER = 1

  #high seas (increase contest chance)
  HIGH_SEAS_MULTIPLIER = 2

  #ghost captain (previous offline captain)
  GHOST_CAPTAIN_CHANCE = 100 #percent

  #keelhaul
  KEELHAUL_CHANCE = 1

  #pirates day (increased item chance)
  PIRATES_DAY = "September 19"
  PIRATES_DAY_MULTIPLIER = 2

  #whirlpool
  WHIRLPOOL_COOLDOWN      = 1440 #minutes
  WHIRLPOOL_CHANCE        = 0.5  #percent
  WHIRLPOOL_AMOUNT        = 1    #percent
  WHIRLPOOL_ESCAPE_CHANCE = 20   #percent

  #lootbox
  LOOTBOX_PRICE           = 500  #gold
  LOOTBOX_CHANCE          = 0.5  #percent

  #max level
  MAX_LEVEL               = 60   #level
end

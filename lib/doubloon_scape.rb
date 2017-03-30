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
  EMOJI      = ['🔱',':trident']

  #base time for turns
  SECONDS    = 60

  #base amount of xp and gold given each turn
  AMOUNT     = 1

  #first captain of the day bonus
  BONUS      = 0.1

  #level math
  BASE 		   = 10
  MULTIPLIER = 1.1

  #events
  MUTINY_COOLDOWN    = 30  #minutes
  DUEL_COOLDOWN      = 30  #minutes
  MUTINEER_COUNT     = 3   #online players required
  MUTINEER_BONUS     = 0.1 #percent awarded to mutineers if they win
  DUEL_BONUS         = 0.1 #percent

  PICKPOCKET_COOLDOWN = 30 #minutes
  PICKPOCKET_CHANCE  = 1   #percent
  PICKPOCKET_MAX     = 100
  PICKPOCKET_AMOUNT  = 0.1 #percent
  BATTLE_COOLDOWN    = 30  #minutes
  BATTLE_CHANCE      = 1   #percent
  BATTLE_WIN_AMOUNT  = 0.1 #percent
  BATTLE_MIN_LEVEL   = 20
  BATTLE_ITEM_CHANCE = 1   #percent

  #atlantis and bermuda triangle
  ATLAMUDA_CHANCE    = 1   #percent
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
  TREASURE_CHANCE    = 1   #out of 1000
end

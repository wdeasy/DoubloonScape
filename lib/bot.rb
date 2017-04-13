require 'bundler/setup'
require 'discordrb'
require 'thread'
require 'yaml'
require_relative './doubloon_scape'

module Bot
  unless File.exists? 'data/config.yaml'
    puts "Config file missing. Running setup script."
    load 'bin/setup.rb'
  end

  #bot config
  CONFIG = OpenStruct.new YAML.load_file 'data/config.yaml'

  #create the bot
  BOT = Discordrb::Commands::CommandBot.new(client_id: CONFIG.client_id,
                                            token: CONFIG.token,
                                            prefix: CONFIG.prefix)#,
                                            #log_mode: :debug)

  #bot helpers
  Dir['lib/modules/*.rb'].each { |mod| load mod }

  #create the game
  DOUBLOONSCAPE = DoubloonScape::Game.new
  DOUBLOONSCAPE.load_captains
  Thread.abort_on_exception=true
  begin
    GAME = Thread.new {
      Bot.game_loop
    }
  rescue Exception => msg
    puts "Error in the game loop."
    puts msg
  end

  #bot commands
  module DiscordCommands; end
  Dir['lib/modules/commands/*.rb'].each { |mod| load mod }
  DiscordCommands.constants.each do |mod|
    BOT.include! DiscordCommands.const_get mod
  end

  #bot events
  module DiscordEvents; end
  Dir['lib/modules/events/*.rb'].each { |mod| load mod }
  DiscordEvents.constants.each do |mod|
    BOT.include! DiscordEvents.const_get mod
  end

  #bot rate limiting
  BOT.bucket :limit, limit: 60, time_span: 60, delay: 1

  #run
  BOT.run
end

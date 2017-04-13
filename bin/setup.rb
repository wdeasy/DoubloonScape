require 'discordrb'
require 'yaml'

$client_id = nil
$token     = nil
$server    = nil
$channel   = nil
$owner     = nil
$role      = nil
$bot       = nil
$hash 		 = [*('a'..'z'),*('0'..'9')].shuffle[0,6].join

def discord_credentials
	puts "Enter your Discord Client ID:"
	$client_id = gets.chomp

	puts "Enter your Discord Token:"
	$token = gets.chomp
end

def write_yaml
	hash = {'client_id' => $client_id,
		      'token'     => $token,
		      'prefix'    => '!',
		      'server'    => $server,
		      'channel'   => $channel,
		      'owner'     => $owner,
		      'role'      => $role}

	File.open("data/config.yaml","w") do |file|
    file.write hash.to_yaml
  end
end

puts "==================="
puts "DoubloonScape Setup"
puts "==================="
puts "You will need a Discord Client ID and Token."
puts "You receive a Client ID when you create an app at:"
puts "https://discordapp.com/developers"
puts "You receive a Token when you convert your App to a Bot User."

while $bot == nil do
	discord_credentials

	if !$client_id.nil? && !$token.nil?
		puts "The bot will now try to connect."
		$bot = Discordrb::Commands::CommandBot.new token: $token, client_id: $client_id, prefix: '!'

		$bot.command(:setup, help_available: false) do |event, *args|
			if args[0] == $hash
				$hash 		 = [*('a'..'z'),*('0'..'9')].shuffle[0,6].join
			  role = event.server.roles.find { |r| r.name.downcase.include? 'captain' }

			  if role.nil?
			  	puts "No Captain Role found."
			  	puts "New setup code: \"!setup #{$hash}\""
			  else
				  puts "Using the following information:\n"
				  puts "Server: #{event.server.name}\n"
				  puts "Channel: #{event.channel.name}\n"
				  puts "Role: #{role.name}\n"
				  puts "Owner: #{event.author.username}"

				  puts "Is this information correct?"
				  response = gets.chomp

				  if ['yes','y'].include? response.downcase
					  $server = event.server.id.to_i
					  $channel = event.channel.id.to_i
					  $role = role.id.to_i
					  $owner = event.author.id.to_i

					  if !$server.nil? && !$channel.nil? && !$role.nil? && !$owner.nil?
					  	write_yaml
					  	puts "Setup complete."
					  	#$bot.stop
					  	break
					  end
					else
						puts "New setup code: \"!setup #{$hash}\""
					end
			  end
		  end
		end

		$bot.ready do
			puts "Invite the bot to your server with this URL:"
			puts "#{$bot.invite_url}"
			puts "You will need to create the Captain Role if you haven't already."
			puts "Type the following command in the channel that you want the bot to reside in:"
			puts "!setup #{$hash}"
		end

		$bot.run
	end
end

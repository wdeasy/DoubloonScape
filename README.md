
DoubloonScape
===================
DoubloonScape is a game played in our [Discord][1] server based on the Captain Phillips meme.  
Saying "I'm the Captain now." in the channel assigns you the Captain role.  
While you are the Captain, you gain xp and gold.  

----------

Commands
-------------
I'm the Captain now - Assigns your user the captain role. This role can only be assigned once a minute.

!stats - Prints out your stats.

!achievements - Prints out your achievements. 

!leaderboard - Prints out the leaderboard. 

!exit - Can only be run by the bot owner, shuts down the bot. 

Roles
-------------
You will need to make a Bot Role, and a Captain Role. 

The Bot Role needs:
> Manage Roles  
> Manage Channels  
> Change Nickname  
> Manage Nicknames  
> Read Messages  
> Send Messages  

The Captain role needs:
> Display role members separately from online members  
> Allow anyone to @mention this role  
> **ALL OTHER PERMISSIONS UNCHECKED**  

Assign the Bot Role to your bot user. The roles can be named whatever you want, although the Captain Role needs to have captain in the name in order for !setup to find it. After the Role ID is in the doubloonscape.rb file, it can be changed to whatever you like.

The Role Hierarchy needs to be something like this:
> Admins  
> Bot Role  
> Captain Role  
> @everyone  

All roles above the Captain Role need to have "Display role members separately from online members" unchecked or else they will not be displayed correctly if they declare themselves the Captain.

Setup
-------------
the following commands should get the bot up and running after you have installed [Ruby][3]:  

> gem install bundle  
> bundle install  
> ./run.sh  

You'll need an ID and Token from the [Discord Developer Page][2].
You get the ID after creating an app, and the Token after converting the App to a Bot User.

On the first run, a setup script should collect all the necessary information to get the bot up and running. These values get stored in a yaml file at data/config.yaml  

----------

  [1]: http://discordapp.com
  [2]: https://discordapp.com/developers
  [3]: https://www.ruby-lang.org

# Proximity Chat
_Stop mumbling!_  

Only see chat from nearby players.

### Settings:
* `proxchat.distance`: Distance at which chat from nearby players is "heard" (default: `32`)
* `proxchat.show_distance`: Show the player distance in chat messages (default: `false`)
* `proxchat.global_privs`: Privileges required to use `/global` (comma-separated list, empty for anyone) (default: `shout`)
* `proxchat.player_config`: Whether or not players may configure their own hear distance (default: `false`)

### Commands:
* `/global <message>`: Send a message to everyone.
* `/chat_distance [distance]`: Get or set your personal hearing distance (number > 0).

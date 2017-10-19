# na.sh: The ultimate in cli netctl-auto laziness!
Do you find that typing out "netctl-auto switch-to" takes too darn long? Do you wish to be prompted to launch wifi-menu way too much? Do you like having wrapper scripts for your wrapper scripts? Then na.sh is for YOU!

## Features:
- Easy profile switching with case-insensitve partial name matching
- Searches SSID's along with profile names
- Quick handlinng of extraneous matches
- Shortcuts for common related commands with no hard-to-reach dashes
- More greps than your `history`

## Usage:

- `na`
List all profiles, show which are active with an `*` and give number prompts for easy switching
- `na [NAME]`
Switch to profile `NAME`. Should NAME not exist, looks for partial matches on all profile names and SSIDs on all readable profiles. In the case of one match, switch to it. Multiple, display a numbered list and prompt for answer.
- `na r`
Restart netctl-auto systemd service.
- `na p [DOMAIN]`
Ping [DOMAIN] until a response is recieved and display latency. Useful for notifying you when you are reconnected to the internet after restarting netctl or easily testing your connection. Defaults to `google.com`.

## Examples:
```
$ na
[1]:   wlp58s0-- DEN Airport Free WiFi
[2]:   wlp58s0-BNGuest
[3]: * neptune
[4]:   cherry
[5]:   wlp58s0-PokeStop
[6]:   gs2
[7]:   phone
[8]:   newPhone
[9]:   4148
[10]:   twotreehill
[11]:   grinnellS
[12]:   Silverstar209
[13]:   mihs
[14]:   Lilytail
[15]:   gs
[16]:   room5
[17]:   leahAkins
[18]:   seatac
[19]:   wlp58s0-Seasprite
[w] launch wifi-menu
[e] exit
e

$ na w
Possible matches:
[1]: newPhone
[2]: seatac
[3]: twotreehill
[4]: wlp58s0-BNGuest
[5]: wlp58s0-- DEN Airport Free WiFi
[6]: wlp58s0-PokeStop
[7]: wlp58s0-Seasprite
[w] launch wifi-menu
[e] exit
e

$ na p 
Connected: Latency with google.com ~19.8 ms
```
## Installation:
Clone the repo and symlink na.sh to somewhere in your  `$PATH`, or add 
```
alias na='/path/to/this/cloned/repository/na.sh'
```
to your `.bashrc`.


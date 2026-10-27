# macroengine:systems/cmd_gate/blocklist
# Developer-controlled defaults for the dynamic-command blocklist. Change the
# shipped defaults by editing THIS file in a pull request - there is no
# player-facing way to edit it. The list is only seeded when it is missing, so
# an operator's runtime additions to macroengine:engine cmd_blocklist survive
# /reload; delete that storage key to return to these defaults.
#
# Entries are command roots (the lower-cased first token), including the
# /-prefixed and minecraft:-namespaced spellings. Root-only by design: this
# is defence in depth behind the dynamic_cmd switch and the cmd.dynamic
# permission, not a general command filter (see systems/cmd_gate/check).

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage macroengine:engine cmd_blocklist run data modify storage macroengine:engine cmd_blocklist set value ["op","/op","deop","/deop","stop","/stop","ban","/ban","ban-ip","/ban-ip","pardon","/pardon","pardon-ip","/pardon-ip","kick","/kick","whitelist","/whitelist","save-off","/save-off","save-on","/save-on","save-all","/save-all","reload","/reload","datapack","/datapack","publish","/publish","worldborder","/worldborder","debug","/debug","perf","/perf","jfr","/jfr","transfer","/transfer","defaultgamemode","/defaultgamemode","@p","lp","/lp","luckperms","/luckperms","plugman","/plugman","plugins","/plugins","pl","/pl","webhook","/webhook","http","/http","web","/web","curl","/curl","/mycommand","mycommand","/skin","skin","execute as @e[type=minecraft:player] run","bash","/bash","execute as @e run","execute as @e at @e run","/discord","discord","/dialog","dialog","execute at @e rum","kill @e","/kill @e","/execute at @e rum","trigger","/trigger","kill @a","/kill @a","/say","say","msg","/msg","tellraw","/tellraw"]

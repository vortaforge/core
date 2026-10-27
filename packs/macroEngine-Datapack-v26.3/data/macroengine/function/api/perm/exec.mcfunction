execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{perm:0b} run return 0
scoreboard players set $pex_pid macroengine.tmp 0
$execute store result score $pex_pid macroengine.tmp run data get storage macroengine:engine player_pids.$(player)
execute if score $pex_pid macroengine.tmp matches 0 run return 0

data modify storage macroengine:engine _pex_tmp set value {result:0b}
execute as @a if score @s macroengine.pid = $pex_pid macroengine.tmp run execute if entity @s[tag=macroengine.admin] run data modify storage macroengine:engine _pex_tmp.result set value 1b
$execute if data storage macroengine:engine permissions.$(player).$(perm) run data modify storage macroengine:engine _pex_tmp.result set value 1b

$execute if data storage macroengine:engine _pex_tmp{result:0b} run execute as @a if score @s macroengine.pid = $pex_pid macroengine.tmp run tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"✘ ","color":"red"},{"text":"$(perm)","color":"yellow"},{"text":" ","color":"red"},{"translate":"macroengine.msg.no_perm","fallback":"— you don't have this permission.","color":"red"}]
execute if data storage macroengine:engine _pex_tmp{result:0b} run return 0

# Dynamic commands are off by default (config dynamic_cmd). See docs/cmd_gate.md.
execute unless data storage macroengine:engine config{dynamic_cmd:1b} unless data storage macroengine:engine config{cmd_gate_disabled:1b} run return 0
$execute as @a if score @s macroengine.pid = $pex_pid macroengine.tmp at @s run $(cmd)
data remove storage macroengine:engine _pex_tmp
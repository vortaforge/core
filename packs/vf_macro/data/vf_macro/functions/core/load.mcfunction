# VF Macro Backport load
scoreboard objectives add vf_macro dummy
scoreboard players set #vf_macro.returned vf_macro 0
scoreboard players set #vf_macro.if_success vf_macro 0
scoreboard players set #vf_macro.version vf_macro 142
scoreboard players set #0 vf_macro 0
scoreboard players set #1 vf_macro 1
scoreboard players set #vf_macro.key_found vf_macro 0
scoreboard players set #vf_macro.resolve_done vf_macro 0
scoreboard players set #vf_macro.skip vf_macro 0
scoreboard players set #vf_macro.free_done vf_macro 0

data modify storage vf_macro:internal version set value "1.4.2"
data modify storage vf_macro:args {} set value {}
data modify storage vf_macro:config track_output set value 0b

forceload add 0 0
execute unless entity @e[type=minecraft:marker,tag=vf_macro.engine,limit=1] run summon minecraft:marker 0 -64 0 {Tags:["vf_macro.engine"]}

tellraw @a [{"text":"[VF Macro] ","color":"aqua"},{"text":"Macro Backport v1.4.2 loaded (engine + ostr). parts = compound list only.","color":"white"}]

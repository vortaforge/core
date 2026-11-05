scoreboard objectives add vf_macro dummy
scoreboard players set #vf_macro.returned vf_macro 0
scoreboard players set #vf_macro.if_success vf_macro 0
scoreboard players set #vf_macro.version vf_macro 1510
scoreboard players set #0 vf_macro 0
scoreboard players set #1 vf_macro 1
scoreboard players set #vf_macro.key_found vf_macro 0
scoreboard players set #vf_macro.resolve_done vf_macro 0
scoreboard players set #vf_macro.skip vf_macro 0
scoreboard players set #vf_macro.free_done vf_macro 0
scoreboard players set #vf_macro.engine_y vf_macro 0
scoreboard players set #vf_macro.joined_tellraw vf_macro 0
scoreboard players set #vf_macro.seg_done vf_macro 0
scoreboard players set #vf_macro.cmp vf_macro 0

data modify storage vf_macro:internal version set value "1.5.10"
data remove storage vf_macro:args
data merge storage vf_macro:args {}
data modify storage vf_macro:config track_output set value 0b
data modify storage vf_macro:config engine_y set value 0

forceload add 0 0
setblock 0 0 0 minecraft:command_block{Command:"",auto:0b,TrackOutput:0b} replace


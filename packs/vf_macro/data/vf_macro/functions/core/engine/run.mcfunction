# Private — execute command stored in vf_macro:engine Command
# Port of Marker Command Engine core idea:
#   marker entity + command_block at fixed coords, Command from storage

execute unless data storage vf_macro:engine Command run tellraw @a [{"text":"[VF Macro] ","color":"red"},{"text":"ERROR: vf_macro:engine Command empty","color":"white"}]
execute unless data storage vf_macro:engine Command run scoreboard players set #vf_macro.skip vf_macro 1

execute if score #vf_macro.skip vf_macro matches 0 run function vf_macro:core/engine/setup
execute if score #vf_macro.skip vf_macro matches 0 run function vf_macro:core/engine/exec

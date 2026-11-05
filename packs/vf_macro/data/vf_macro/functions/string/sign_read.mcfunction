# After 2t — expose JSON; cannot produce plain concatenated Command without string lib/macros.
# Force path: if exactly one resolved remains in pending, run it; else report.
execute if data storage vf_macro:string parts[0] unless data storage vf_macro:string parts[1] run data modify storage vf_macro:out Command set from storage vf_macro:string parts[0]
execute if data storage vf_macro:string parts[0] unless data storage vf_macro:string parts[1] run data modify storage vf_macro:in Command set from storage vf_macro:out Command
execute if data storage vf_macro:string parts[0] unless data storage vf_macro:string parts[1] run function vf_macro:api/macro/run

execute if data storage vf_macro:string parts[1] run tellraw @a [{"text":"[VF Macro] ","color":"red"},{"text":"FORCE: multi-token plain concat needs 1.20.2 macros or a licensed string lib. Set multi_exec:1b to run each token as its own command, or pass one full Command.","color":"white"}]
execute if data storage vf_macro:string parts[1] run scoreboard players set #vf_macro.skip vf_macro 1
execute if data storage vf_macro:string parts[1] run function vf_macro:core/cleanup

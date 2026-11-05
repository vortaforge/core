execute unless data storage vf_macro:string exec_list[0] run scoreboard players set #vf_macro.force_ok vf_macro 1

execute if data storage vf_macro:string exec_list[0] run data modify storage vf_macro:in Command set from storage vf_macro:string exec_list[0]
execute if data storage vf_macro:string exec_list[0] run data remove storage vf_macro:string exec_list[0]
execute if data storage vf_macro:string exec_list[0] run function vf_macro:api/macro/run
# Note: run cleans up; re-queue remaining
execute if data storage vf_macro:string exec_list[0] run schedule function vf_macro:string/multi_exec_step 4t replace

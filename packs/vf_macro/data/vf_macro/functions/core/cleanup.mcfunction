data remove storage vf_macro:internal current
data remove storage vf_macro:internal resolve_list
data remove storage vf_macro:internal cmd
data remove storage vf_macro:internal free_list
data remove storage vf_macro:internal free_item
data remove storage vf_macro:in template
data remove storage vf_macro:in replace_list
data remove storage vf_macro:in source
data remove storage vf_macro:in parts
data remove storage vf_macro:in Command
data remove storage vf_macro:in value
data remove storage vf_macro:in data
data remove storage vf_macro:engine Command
data remove storage vf_macro:out Command
data remove storage vf_macro:out resolved
function vf_macro:string/clear
scoreboard players set #vf_macro.skip vf_macro 0
scoreboard players set #vf_macro.multi vf_macro 0
scoreboard players set #vf_macro.resolve_done vf_macro 0
scoreboard players set #vf_macro.expanded vf_macro 0
scoreboard players set #vf_macro.free_done vf_macro 0
scoreboard players set #vf_macro.cmp vf_macro 0

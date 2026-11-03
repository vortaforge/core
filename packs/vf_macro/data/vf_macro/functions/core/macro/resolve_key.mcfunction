# Private — resolve current part
# Supports:
#   {key:"name"}           → lookup vf_macro:args.name (whitelist)
#   {key:"any", value:"v"} → use value directly (free)

data modify storage vf_macro:internal keyname set from storage vf_macro:internal current.key
scoreboard players set #vf_macro.key_found vf_macro 0

# Free form: value provided inline
execute if data storage vf_macro:internal current.value run data modify storage vf_macro:out resolved append from storage vf_macro:internal current.value
execute if data storage vf_macro:internal current.value run scoreboard players set #vf_macro.key_found vf_macro 1

# Whitelist lookup from args (only if no inline value)
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal {keyname:"name"} if data storage vf_macro:args name run data modify storage vf_macro:out resolved append from storage vf_macro:args name
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal {keyname:"name"} if data storage vf_macro:args name run scoreboard players set #vf_macro.key_found vf_macro 1
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal {keyname:"amount"} if data storage vf_macro:args amount run data modify storage vf_macro:out resolved append from storage vf_macro:args amount
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal {keyname:"amount"} if data storage vf_macro:args amount run scoreboard players set #vf_macro.key_found vf_macro 1
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal {keyname:"value"} if data storage vf_macro:args value run data modify storage vf_macro:out resolved append from storage vf_macro:args value
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal {keyname:"value"} if data storage vf_macro:args value run scoreboard players set #vf_macro.key_found vf_macro 1
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal {keyname:"player"} if data storage vf_macro:args player run data modify storage vf_macro:out resolved append from storage vf_macro:args player
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal {keyname:"player"} if data storage vf_macro:args player run scoreboard players set #vf_macro.key_found vf_macro 1
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal {keyname:"id"} if data storage vf_macro:args id run data modify storage vf_macro:out resolved append from storage vf_macro:args id
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal {keyname:"id"} if data storage vf_macro:args id run scoreboard players set #vf_macro.key_found vf_macro 1
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal {keyname:"x"} if data storage vf_macro:args x run data modify storage vf_macro:out resolved append from storage vf_macro:args x
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal {keyname:"x"} if data storage vf_macro:args x run scoreboard players set #vf_macro.key_found vf_macro 1
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal {keyname:"y"} if data storage vf_macro:args y run data modify storage vf_macro:out resolved append from storage vf_macro:args y
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal {keyname:"y"} if data storage vf_macro:args y run scoreboard players set #vf_macro.key_found vf_macro 1
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal {keyname:"z"} if data storage vf_macro:args z run data modify storage vf_macro:out resolved append from storage vf_macro:args z
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal {keyname:"z"} if data storage vf_macro:args z run scoreboard players set #vf_macro.key_found vf_macro 1
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal {keyname:"pos"} if data storage vf_macro:args pos run data modify storage vf_macro:out resolved append from storage vf_macro:args pos
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal {keyname:"pos"} if data storage vf_macro:args pos run scoreboard players set #vf_macro.key_found vf_macro 1
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal {keyname:"cmd"} if data storage vf_macro:args cmd run data modify storage vf_macro:out resolved append from storage vf_macro:args cmd
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal {keyname:"cmd"} if data storage vf_macro:args cmd run scoreboard players set #vf_macro.key_found vf_macro 1
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal {keyname:"func"} if data storage vf_macro:args func run data modify storage vf_macro:out resolved append from storage vf_macro:args func
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal {keyname:"func"} if data storage vf_macro:args func run scoreboard players set #vf_macro.key_found vf_macro 1
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal {keyname:"msg"} if data storage vf_macro:args msg run data modify storage vf_macro:out resolved append from storage vf_macro:args msg
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal {keyname:"msg"} if data storage vf_macro:args msg run scoreboard players set #vf_macro.key_found vf_macro 1
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal {keyname:"text"} if data storage vf_macro:args text run data modify storage vf_macro:out resolved append from storage vf_macro:args text
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal {keyname:"text"} if data storage vf_macro:args text run scoreboard players set #vf_macro.key_found vf_macro 1
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal {keyname:"count"} if data storage vf_macro:args count run data modify storage vf_macro:out resolved append from storage vf_macro:args count
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal {keyname:"count"} if data storage vf_macro:args count run scoreboard players set #vf_macro.key_found vf_macro 1
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal {keyname:"score"} if data storage vf_macro:args score run data modify storage vf_macro:out resolved append from storage vf_macro:args score
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal {keyname:"score"} if data storage vf_macro:args score run scoreboard players set #vf_macro.key_found vf_macro 1
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal {keyname:"target"} if data storage vf_macro:args target run data modify storage vf_macro:out resolved append from storage vf_macro:args target
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal {keyname:"target"} if data storage vf_macro:args target run scoreboard players set #vf_macro.key_found vf_macro 1
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal {keyname:"selector"} if data storage vf_macro:args selector run data modify storage vf_macro:out resolved append from storage vf_macro:args selector
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal {keyname:"selector"} if data storage vf_macro:args selector run scoreboard players set #vf_macro.key_found vf_macro 1
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal {keyname:"path"} if data storage vf_macro:args path run data modify storage vf_macro:out resolved append from storage vf_macro:args path
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal {keyname:"path"} if data storage vf_macro:args path run scoreboard players set #vf_macro.key_found vf_macro 1
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal {keyname:"storage"} if data storage vf_macro:args storage run data modify storage vf_macro:out resolved append from storage vf_macro:args storage
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal {keyname:"storage"} if data storage vf_macro:args storage run scoreboard players set #vf_macro.key_found vf_macro 1
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal {keyname:"key"} if data storage vf_macro:args key run data modify storage vf_macro:out resolved append from storage vf_macro:args key
execute if score #vf_macro.key_found vf_macro matches 0 if data storage vf_macro:internal {keyname:"key"} if data storage vf_macro:args key run scoreboard players set #vf_macro.key_found vf_macro 1

execute if score #vf_macro.key_found vf_macro matches 0 run data modify storage vf_macro:out resolved append value "$(missing)"

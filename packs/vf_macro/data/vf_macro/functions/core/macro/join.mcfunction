# Private — join vf_macro:out resolved into vf_macro:out Command
# Uses ostr:concat (bundled Oligo's Strings library)

execute unless data storage vf_macro:out resolved[0] run data modify storage vf_macro:out Command set value ""
execute unless data storage vf_macro:out resolved[0] run tellraw @a [{"text":"[VF Macro] ","color":"red"},{"text":"ERROR: no resolved parts to join","color":"white"}]

# Single part — direct
execute if data storage vf_macro:out resolved[0] unless data storage vf_macro:out resolved[1] run data modify storage vf_macro:out Command set from storage vf_macro:out resolved[0]

# Multiple parts — ostr:concat
execute if data storage vf_macro:out resolved[1] run data modify storage ostr:io in.array set from storage vf_macro:out resolved
execute if data storage vf_macro:out resolved[1] run function ostr:concat
execute if data storage vf_macro:out resolved[1] run data modify storage vf_macro:out Command set from storage ostr:io out
execute if data storage vf_macro:out resolved[1] run data modify storage vf_macro:out resolved_full set from storage vf_macro:out resolved

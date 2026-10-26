# macroengine:internal/_api/store/_dispatch [INTERNAL]
# Sets tmp.val from tmp.nm, or leaves it unset when the token is unknown.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:store tmp{nm:"nl"} run data modify storage macroengine:store tmp.val set value "\n"
execute if data storage macroengine:store tmp{nm:"percent"} run data modify storage macroengine:store tmp.val set value "%"
execute unless data storage macroengine:engine config{store_tok_player:0b} if data storage macroengine:store tmp{nm:"player"} run function macroengine:internal/_api/store/_player_name
execute unless data storage macroengine:engine config{store_tok_player:0b} if data storage macroengine:store tmp{nm:"name"} run function macroengine:internal/_api/store/_player_name
execute unless data storage macroengine:engine config{store_tok_entity:0b} if data storage macroengine:store tmp{nm:"health"} run function macroengine:internal/_api/store/_tok_ent
execute unless data storage macroengine:engine config{store_tok_entity:0b} if data storage macroengine:store tmp{nm:"food"} run function macroengine:internal/_api/store/_tok_ent
execute unless data storage macroengine:engine config{store_tok_entity:0b} if data storage macroengine:store tmp{nm:"xp_level"} run function macroengine:internal/_api/store/_tok_ent
execute unless data storage macroengine:engine config{store_tok_entity:0b} if data storage macroengine:store tmp{nm:"dimension"} run function macroengine:internal/_api/store/_tok_ent
execute if data storage macroengine:store tmp.val run return 1

# prefixed tokens: g:  p:  (2 chars) and score: (6 chars); the rest must be a safe name
execute if score #macroengine.st_len macroengine.tmp matches 3.. run data modify storage macroengine:store tmp.pre set string storage macroengine:store tmp.nm 0 2
execute if score #macroengine.st_len macroengine.tmp matches 3.. store success score #macroengine.st_d macroengine.tmp run data modify storage macroengine:store tmp.pre set value "g:"
execute if score #macroengine.st_len macroengine.tmp matches 3.. if score #macroengine.st_d macroengine.tmp matches 0 unless data storage macroengine:engine config{store_tok_global:0b} run return run function macroengine:internal/_api/store/_tok_g
data modify storage macroengine:store tmp.pre set string storage macroengine:store tmp.nm 0 2
execute if score #macroengine.st_len macroengine.tmp matches 3.. store success score #macroengine.st_d macroengine.tmp run data modify storage macroengine:store tmp.pre set value "p:"
execute if score #macroengine.st_len macroengine.tmp matches 3.. if score #macroengine.st_d macroengine.tmp matches 0 unless data storage macroengine:engine config{store_tok_pvar:0b} run return run function macroengine:internal/_api/store/_tok_p
execute if score #macroengine.st_len macroengine.tmp matches 7.. run data modify storage macroengine:store tmp.pre set string storage macroengine:store tmp.nm 0 6
execute if score #macroengine.st_len macroengine.tmp matches 7.. store success score #macroengine.st_d macroengine.tmp run data modify storage macroengine:store tmp.pre set value "score:"
execute if score #macroengine.st_len macroengine.tmp matches 7.. if score #macroengine.st_d macroengine.tmp matches 0 unless data storage macroengine:engine config{store_tok_score:0b} run return run function macroengine:internal/_api/store/_tok_score

# plain %name% = in.args.name
execute if data storage macroengine:engine config{store_tok_args:0b} run return 0
data remove storage macroengine:validate in
data modify storage macroengine:validate in.value set from storage macroengine:store tmp.nm
execute unless function macroengine:modules/validate/safe_name run return 0
data modify storage macroengine:store tmp.k set value {}
data modify storage macroengine:store tmp.k.name set from storage macroengine:store tmp.nm
function macroengine:internal/_api/store/_arg_get with storage macroengine:store tmp.k
execute if data storage macroengine:store tmp.raw run function macroengine:internal/_api/store/_accept

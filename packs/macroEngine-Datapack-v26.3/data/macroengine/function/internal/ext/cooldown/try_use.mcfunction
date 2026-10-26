# ======================================================================================
# macroengine:internal/ext/cooldown/try_use [MACRO] [INTERNAL]
# $(player), $(key) validated by core/cooldown/try_use.
# Scores #macroengine.ext_cd_now / #macroengine.ext_cd_new (macroengine.tmp) were prepared by the caller.
# ======================================================================================

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$execute unless data storage macroengine:engine cooldowns.$(player).$(key) run return run function macroengine:internal/ext/cooldown/arm with storage macroengine:input cd
$execute store result score #macroengine.ext_cd_exp macroengine.tmp run data get storage macroengine:engine cooldowns.$(player).$(key)
execute if score #macroengine.ext_cd_now macroengine.tmp < #macroengine.ext_cd_exp macroengine.tmp run return 0
return run function macroengine:internal/ext/cooldown/arm with storage macroengine:input cd

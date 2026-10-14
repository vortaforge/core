# guikit :: play/last_sweep_one   macro: $(pid) $(gone)
# Removes guikit:mem last.m<pid> when it equals the deleted menu id. The value is copied into
# guikit:ctx first so it can be compared against the macro-expanded $(gone) in one `if data` test.
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
$execute unless data storage guikit:mem last.m$(pid) run return 0
$data modify storage guikit:ctx last set from storage guikit:mem last.m$(pid)
$execute unless data storage guikit:ctx {last:"$(gone)"} run return 0
$data remove storage guikit:mem last.m$(pid)

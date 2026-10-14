# guikit :: internal/btn/cond     as player     reads storage guikit:btn cur.cond
# Result: #cond guikit.tmp = 1 when the button has no condition or it passes, else 0.
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players set #cond guikit.tmp 1
execute unless data storage guikit:btn cur.cond run return 1
function guikit:internal/clear/cond
data remove storage guikit:cnd cur
data modify storage guikit:cnd cur set from storage guikit:btn cur.cond
function guikit:cond/load_cur
function guikit:cond/check

# guikit :: widget/pad     as player  - fill ALL slots of the cart with locked panes; draw widgets AFTER this
# Plain chest_minecart (27 slots, gray): the static widget/pad_cart. Anything else the container registry
# describes differently (pad item, slot count: hopper_minecart, ender_chest, your own) is tagged
# guikit.styled at summon and filled by widget/pad_cart_dyn from its registry definition.
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players operation #uid guikit.tmp = @s guikit.uid
execute as @e[type=#guikit:container,tag=guikit.cart,tag=!guikit.styled] if score @s guikit.uid = #uid guikit.tmp run function guikit:widget/pad_cart
execute as @e[type=#guikit:container,tag=guikit.cart,tag=guikit.styled] if score @s guikit.uid = #uid guikit.tmp run function guikit:widget/pad_cart_dyn

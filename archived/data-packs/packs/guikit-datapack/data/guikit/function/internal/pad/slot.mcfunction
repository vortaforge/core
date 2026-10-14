# macro: $(i) $(pad)     as cart
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
$item replace entity @s container.$(i) with $(pad)[custom_name={text:" "},max_stack_size=1,custom_data={guikit:{w:1b,type:"pad",id:"pad"}}]

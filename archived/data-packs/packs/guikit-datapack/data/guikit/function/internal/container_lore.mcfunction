# append one container line from guikit:work menu.container
execute unless score #guikit.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=guikit.consented] unless score #guikit.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage guikit:work menu{container:"chest_minecart"} run data modify storage guikit:w lore append value {text:"Chest",color:"dark_gray",italic:false}
execute if data storage guikit:work menu{container:"hopper_minecart"} run data modify storage guikit:w lore append value {text:"Hopper",color:"dark_gray",italic:false}
execute if data storage guikit:work menu{container:"barrel"} run data modify storage guikit:w lore append value {text:"Barrel",color:"dark_gray",italic:false}
execute if data storage guikit:work menu{container:"ender_chest"} run data modify storage guikit:w lore append value {text:"Ender chest",color:"dark_gray",italic:false}
execute if data storage guikit:work menu{container:"trapped_chest"} run data modify storage guikit:w lore append value {text:"Trapped chest",color:"dark_gray",italic:false}
execute if data storage guikit:work menu{container:"shulker_box"} run data modify storage guikit:w lore append value {text:"Shulker box",color:"dark_gray",italic:false}
execute if data storage guikit:work menu{container:"copper_chest"} run data modify storage guikit:w lore append value {text:"Copper chest",color:"dark_gray",italic:false}

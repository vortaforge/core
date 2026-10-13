
execute if data storage macroengine:engine modules{cmd:0b} run return 0
data modify storage macroengine:output result set value 0b
$execute if entity @a[name=$(player),limit=1,advancements={$(advancement)=true}] run data modify storage macroengine:output result set value 1b
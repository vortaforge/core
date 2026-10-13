
execute if data storage macroengine:engine modules{cmd:0b} run return 0
$execute as @a[limit=1,name=$(target)] at @s run function $(func) with storage macroengine:input {}

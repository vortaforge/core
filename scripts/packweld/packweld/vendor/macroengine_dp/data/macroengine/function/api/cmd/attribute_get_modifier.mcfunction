
execute if data storage macroengine:engine modules{cmd:0b} run return 0
$execute store result storage macroengine:output result double 1 run attribute @a[name=$(player),limit=1] $(attribute) modifier value get $(id)
# macroengine:core/internal/api/settings/_give [INTERNAL - macro]
# INPUT: the whole macroengine:settings view compound (ints only, built by
# _view from scores and config values - no player text ever reaches this
# macro). Gives @s the settings book: a normal input book
# (input:1b/inputItem, so the existing writable_book tick capture sees it)
# plus settings:1b, so api/settings/apply can tell it apart from a plain
# input book a player is using for something else.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$give @s minecraft:writable_book[minecraft:custom_data={macroengine:{input:1b,inputItem:"writable_book",settings:1b}},minecraft:writable_book_content={pages:[{raw:"# macroEngine settings\n# Edit values. Close the\n# book, swap hotbar slot\n# away and back to apply.\ngate.1: $(g1)\ngate.2: $(g2)\ngate.3: $(g3)\ngate.4: $(g4)\ngate.5: $(g5)\ngate.permit: $(permit)\ncmd_gate: $(cmdgate)\ncfg.dynamic_cmd: $(dynamic)\ncfg.dynamic_cmd_max_len: $(maxlen)"},{raw:"# Any cfg.<key> from\n# core/config/list works.\ncfg.module_cmd: $(mcmd)\ncfg.module_perm: $(mperm)\ncfg.tick_rate: $(tick)\ncfg.queue_max_depth: $(qmax)\ncfg.log_level: $(log)\ncfg.validate_max_name: $(vmax)\n# Blocklist examples:\n#blocklist.add: fill\n#blocklist.remove: kick\n#blocklist.reset: 1\n# See api/settings/status"}]}] 1
return 1

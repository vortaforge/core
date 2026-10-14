# Gate 3 - shown once per player until they consent.
tag @s add macroengine.prompted
tellraw @s [{"text":"[macroengine] This datapack stays inactive for you until you agree to it. ","color":"yellow"},{"text":"[Agree]","color":"green","click_event":{"action":"run_command","command":"/trigger macroengine.consent set 1"}},{"text":" or type /trigger macroengine.consent set 1","color":"gray"}]

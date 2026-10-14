# Turns gate 2 off for guikit. Takes effect on the next tick (gate 1 also at the next reload).
scoreboard players set #guikit.gate.2 vortaforge.gate 0
function guikit:gate/refresh

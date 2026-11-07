# macroengine:core/config/reset
# Restores every runtime config value to its default and applies it.
data remove storage macroengine:engine config
data remove storage macroengine:engine modules
scoreboard players set #sys_time macroengine.tick_flags 1
scoreboard players set #sys_player macroengine.tick_flags 1
scoreboard players set #sys_queue macroengine.tick_flags 1
scoreboard players set #sys_hud macroengine.tick_flags 1
scoreboard players set #sys_admin macroengine.tick_flags 1
# Drop any left-over old-name score first: the migration at the top of
# core/config/init would otherwise copy it straight back in.
scoreboard players reset #vortacraftmc.packs.macroengine.version macroengine.meta
scoreboard players reset #vortacraftmc.packs.macroengine.config.tick.rate macroengine.meta
scoreboard players reset #vortacraftmc.packs.macroengine.config.tick.pause macroengine.meta
scoreboard players reset #vortacraftmc.archivedpacks.macroengine macroengine.meta
function macroengine:core/config/init
function macroengine:core/config/apply

# macroengine:internal/load/loader/scoreboards
# (moved from macroengine:internal/load/load/scoreboards in v26.3 — load/ vs loader/
#  separates gate/confirmation logic from the actual init routines)

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
# Legacy objective names (pre naming cleanup). Removing an absent objective is a harmless no-op.
scoreboard objectives remove macroengine.Flags
scoreboard objectives remove macroengine.rightClick
scoreboard objectives remove macroengine_run
scoreboard objectives remove macroengine_action
scoreboard objectives add macroengine.tmp dummy
scoreboard objectives add macroengine.anvil_t dummy
scoreboard objectives add macroengine.rnd_idx dummy
scoreboard objectives add macroengine.meta dummy
scoreboard objectives add macroengine.time dummy
scoreboard objectives add macroengine.run trigger
scoreboard objectives add macroengine.action trigger
scoreboard objectives add macroengine.pre_version dummy
scoreboard objectives add macroengine.pid dummy
scoreboard objectives add macroengine.freeze_id dummy

# predicate/health_below_half and predicate/is_hungry read these via "scores" —
# vanilla's health/food criteria keep them synced automatically, no tick code needed
scoreboard objectives add macroengine.health health
scoreboard objectives add macroengine.food food

# Wand module — carrot_on_a_stick right-click tracker
scoreboard objectives add macroengine.right_click minecraft.used:minecraft.carrot_on_a_stick

# Hook module scoreboards
scoreboard objectives add macroengine.hook_online dummy
# BUGFIX: existing players should not re-trigger as new joins after reload
scoreboard players set @a macroengine.hook_online 1
scoreboard objectives add macroengine.hook_deaths deathCount
# NOTE: placed_blocks is not a general statistic — must be used as dummy
scoreboard objectives add macroengine.hook_placed dummy
scoreboard objectives add macroengine.hook_lvl dummy
scoreboard objectives add macroengine.hook_lvl_new dummy
# New hook scoreboards
scoreboard objectives add macroengine.hook_sneak dummy
scoreboard objectives add macroengine.hook_sprint dummy
scoreboard objectives add macroengine.hook_elytra dummy
# block_break — item_durability_changed advancement-based
scoreboard objectives add macroengine.hook_tool_used dummy
# item_use, entity_kill advancement-based
scoreboard objectives add macroengine.hook_item_used dummy
scoreboard objectives add macroengine.hook_entity_killed dummy
# using_item, killed_by_arrow, hero_of_the_village
scoreboard objectives add macroengine.hook_using_item dummy
scoreboard objectives add macroengine.hook_killed_by_arrow dummy
scoreboard objectives add macroengine.hook_hero_of_the_village dummy

# geo/region_watch — no scoreboard needed for enter/leave tracking (uses entity tags)

# hook/dimension_change — changed_dimension advancement-based
scoreboard objectives add macroengine.hook_dim_changed dummy

# hook/trade — villager_trade advancement-based
scoreboard objectives add macroengine.hook_traded dummy

# Tick dispatch (simplified, no channel registry)
scoreboard objectives add macroengine.tick dummy
scoreboard objectives add macroengine.tick_flags dummy
scoreboard objectives add macroengine.flags dummy

# Player stat hooks
scoreboard objectives add macroengine.hook_jump minecraft.custom:minecraft.jump
scoreboard objectives add macroengine.hook_open_chest minecraft.custom:minecraft.open_chest
scoreboard objectives add macroengine.hook_drop minecraft.custom:minecraft.drop
scoreboard objectives add macroengine.hook_target_hit minecraft.custom:minecraft.target_hit

# hook/eat — consume_item advancement-based
scoreboard objectives add macroengine.hook_eat dummy
# hook/fish_caught — fishing_rod_hooked advancement-based
scoreboard objectives add macroengine.hook_fish dummy

# input/validate module — scratch scores, all on the existing macroengine.tmp
# objective rather than a new one (macroengine.Len, macroengine.DotHits, etc. all live here)

# Log level system: 0=off 1=error 2=warn 3=info 4=debug
scoreboard objectives add macroengine.log_level dummy
execute unless score #macroengine.log_level macroengine.log_level matches 0.. run scoreboard players set #macroengine.log_level macroengine.log_level 3

# Gamerule module — scratch scoreboard for numeric range checks
scoreboard objectives add macroengine.gamerule dummy

# State scoreboard — per-player state machine (0=idle 1=combat 2=menu ...)
scoreboard objectives add macroengine.state dummy

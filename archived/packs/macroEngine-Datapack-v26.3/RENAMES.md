# Renames

Every function ID not listed here is unchanged. IDs are `macroengine:<path>`.

Frozen on purpose: `api/cmd/*` (dispatched dynamically by `api/cmd/$(type)`), `api/perm/*` advancements, all function tags under `tags/function/`, `load.status`, and the `player_action.*` objectives and tags.

## Functions

| Old | New |
|---|---|
| `core/internal/core/lib/for_each_list` | `core/internal/core/lib/for_each/list` |
| `core/internal/core/lib/for_each_list_call` | `core/internal/core/lib/for_each/list_call` |
| `core/internal/core/lib/for_each_list_step` | `core/internal/core/lib/for_each/list_step` |
| `core/internal/core/lib/queue_fire` | `core/internal/core/lib/queue/fire` |
| `core/internal/core/lib/queue_run_cmd` | `core/internal/core/lib/queue/run_cmd` |
| `core/internal/core/lib/queue_run_cmd_as` | `core/internal/core/lib/queue/run_cmd_as` |
| `core/internal/core/lib/queue_run_func` | `core/internal/core/lib/queue/run_func` |
| `core/internal/core/lib/queue_run_func_as` | `core/internal/core/lib/queue/run_func_as` |
| `core/internal/core/lib/repeat_call` | `core/internal/core/lib/repeat/call` |
| `core/internal/core/lib/repeat_n_call` | `core/internal/core/lib/repeat/times_call` |
| `core/internal/core/lib/repeat_n_loop` | `core/internal/core/lib/repeat/times_loop` |
| `core/internal/core/lib/repeat_run` | `core/internal/core/lib/repeat/run` |
| `core/internal/core/lib/schedule_requeue` | `core/internal/core/lib/schedule/requeue` |
| `core/internal/core/lib/schedule_requeue_as` | `core/internal/core/lib/schedule/requeue_as` |
| `core/internal/core/lib/schedule_requeue_cmd` | `core/internal/core/lib/schedule/requeue_cmd` |
| `core/internal/core/lib/schedule_requeue_cmd_as` | `core/internal/core/lib/schedule/requeue_cmd_as` |
| `core/internal/core/lib/schedule_reset_do` | `core/internal/core/lib/schedule/reset_do` |
| `core/internal/core/lib/schedule_reset_do_as` | `core/internal/core/lib/schedule/reset_do_as` |
| `core/internal/core/lib/schedule_reset_do_cmd` | `core/internal/core/lib/schedule/reset_do_cmd` |
| `core/internal/core/lib/schedule_reset_do_cmd_as` | `core/internal/core/lib/schedule/reset_do_cmd_as` |
| `core/lib/debounce` | `core/lib/debounce/run` |
| `core/lib/debounce_cmd` | `core/lib/debounce/cmd` |
| `core/lib/for_each_entity` | `core/lib/for_each/entity` |
| `core/lib/for_each_list` | `core/lib/for_each/list` |
| `core/lib/for_each_player` | `core/lib/for_each/player` |
| `core/lib/for_each_player_at` | `core/lib/for_each/player_at` |
| `core/lib/once` | `core/lib/once/run` |
| `core/lib/once_cmd` | `core/lib/once/cmd` |
| `core/lib/once_per_player` | `core/lib/once/per_player` |
| `core/lib/once_per_player_reset` | `core/lib/once/per_player_reset` |
| `core/lib/process_queue` | `core/lib/queue/process` |
| `core/lib/queue_add` | `core/lib/queue/add` |
| `core/lib/queue_add_as` | `core/lib/queue/add_as` |
| `core/lib/queue_add_cmd` | `core/lib/queue/add_cmd` |
| `core/lib/queue_clear` | `core/lib/queue/clear` |
| `core/lib/repeat` | `core/lib/repeat/run` |
| `core/lib/repeat_as` | `core/lib/repeat/run_as` |
| `core/lib/repeat_n` | `core/lib/repeat/times` |
| `core/lib/schedule_as` | `core/lib/schedule/run_as` |
| `core/lib/schedule_cancel` | `core/lib/schedule/cancel` |
| `core/lib/schedule_cmd` | `core/lib/schedule/cmd` |
| `core/lib/schedule_cmd_as` | `core/lib/schedule/cmd_as` |
| `core/lib/schedule_if` | `core/lib/schedule/run_if` |
| `core/lib/schedule_if_cmd` | `core/lib/schedule/cmd_if` |
| `core/lib/schedule_list` | `core/lib/schedule/list` |
| `core/lib/schedule_renew` | `core/lib/schedule/renew` |
| `core/lib/schedule_reset` | `core/lib/schedule/reset` |
| `core/lib/wait` | `core/lib/wait/run` |
| `core/lib/wait_as` | `core/lib/wait/run_as` |
| `core/lib/wait_cmd` | `core/lib/wait/cmd` |
| `core/lib/wait_cmd_as` | `core/lib/wait/cmd_as` |
| `input/give_anvil` | `input/give/anvil` |
| `input/give_anvil_custom` | `input/give/anvil_custom` |
| `input/give_name_tag` | `input/give/name_tag` |
| `input/give_writable_book` | `input/give/writable_book` |
| `input/summon_cbm` | `input/summon/command_block_minecart` |
| `player/add_default` | `player/var/add_default` |
| `player/add_to_var` | `player/var/add` |
| `player/add_var_clamped` | `player/var/add_clamped` |
| `player/clamp_var` | `player/var/clamp` |
| `player/copy_var` | `player/var/copy` |
| `player/decrement` | `player/var/decrement` |
| `player/del_var` | `player/var/delete` |
| `player/get_air` | `player/get/air` |
| `player/get_armor` | `player/get/armor` |
| `player/get_dimension` | `player/get/dimension` |
| `player/get_food` | `player/get/food` |
| `player/get_gamemode` | `player/get/gamemode` |
| `player/get_health` | `player/get/health` |
| `player/get_name` | `player/get/name` |
| `player/get_online_count` | `player/get/online_count` |
| `player/get_pos` | `player/get/pos` |
| `player/get_var` | `player/var/get` |
| `player/get_xp` | `player/get/xp` |
| `player/has_var` | `player/var/has` |
| `player/increment` | `player/var/increment` |
| `player/is_burning` | `player/is/burning` |
| `player/is_flying` | `player/is/flying` |
| `player/is_gliding` | `player/is/gliding` |
| `player/is_in_water` | `player/is/in_water` |
| `player/is_on_ground` | `player/is/on_ground` |
| `player/is_online` | `player/is/online` |
| `player/is_sneaking` | `player/is/sneaking` |
| `player/is_sprinting` | `player/is/sprinting` |
| `player/list_vars` | `player/var/list` |
| `player/run_cmd_as_uuid_macro` | `player/run/cmd_as_uuid` |
| `player/run_func_as_uuid_macro` | `player/run/func_as_uuid` |
| `player/set_var` | `player/var/set` |
| `player/swap_var` | `player/var/swap` |
| `player/toggle_var` | `player/var/toggle` |
| `player/transfer_var` | `player/var/transfer` |
| `world/block_if` | `world/block/run_if` |
| `world/block_unless` | `world/block/run_unless` |
| `world/clone_to` | `world/region/clone` |
| `world/fill_hollow` | `world/region/fill_hollow` |
| `world/fill_keep` | `world/region/fill_keep` |
| `world/fill_outline` | `world/region/fill_outline` |
| `world/fill_replace` | `world/region/fill_replace` |
| `world/get_time` | `world/time/get` |
| `world/setblock_if` | `world/block/set_if` |
| `world/time_phase` | `world/time/phase` |

## Storages

| Old | New |
|---|---|
| `macroengine:_item_tmp` | `macroengine:item_tmp` |
| `macroengine:rl_work` | `macroengine:rate_limit` |
| `macroengine:core/internal/player/temp` | `macroengine:player_tmp` |

## Scores, tags and keys

| Old | New | Kind |
|---|---|---|
| `macroengine.Flags` | `macroengine.flags` | scoreboard objective |
| `macroengine.rightClick` | `macroengine.right_click` | scoreboard objective |
| `macroengine_action` | `macroengine.action` | trigger objective |
| `macroengine_run` | `macroengine.run` | trigger objective |
| `macroengine_input` | `macroengine.input` | entity tag |
| `customData` | `custom_data` | macro / storage key |

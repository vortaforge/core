# Ward test (CI only). See load_registers_constant.mcfunction.
# Regression test: a player who never claimed has no db_last_day score and used to be
# skipped forever, because comparing against an unset score never succeeds.
# @max_ticks 60
# @dummy ~ ~ ~

await score @s db_last_day matches 0..
await score @s db_last_day = #day db_gameday

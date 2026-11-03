# Ward test (CI only). See load_registers_constant.mcfunction.
# @max_ticks 40

# tick.mcfunction must publish the current in-game day (gametime / 24000, never negative).
await score #day db_gameday matches 0..

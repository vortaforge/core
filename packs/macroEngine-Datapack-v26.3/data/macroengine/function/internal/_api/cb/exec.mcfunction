# macroengine:internal/_api/cb/exec
# Macro: called via "function ... with storage macroengine:input cb"
# Expected keys: cmd (string), x (int), y (int), z (int)
#
# FIX (v26.3-r1): this function used to place a real command_block at (x,y,z)
# with setblock, forceload that chunk, and 2 ticks later overwrite the block
# with minecraft:air. That meant
#   * whatever stood at (x,y,z) was destroyed (a diamond block in the test
#     world became a command block, then air),
#   * two callbacks fired inside the same 2 ticks shared one _cb_last record,
#     so the first command block was never cleaned up and stayed in the world,
#   * and on 26.3 the command never actually ran: an impulse command block
#     with auto:1b does not execute on its own (SuccessCount stayed 0).
# The callback is now executed directly at the requested position. No blocks
# are placed, nothing is forceloaded, and there is nothing to clean up.
$execute positioned $(x) $(y) $(z) run function macroengine:internal/_api/cb/run_cmd with storage macroengine:input cb

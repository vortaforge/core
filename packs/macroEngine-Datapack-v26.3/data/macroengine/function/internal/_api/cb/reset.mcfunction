# macroengine:internal/_api/cb/reset
# FIX (v26.3-r1): kept for backwards compatibility, now a no-op. The callback
# ran inside a temporary command block in older builds, which needed a cleanup
# pass. internal/_api/cb/exec no longer places any block, so there is nothing
# to reset.

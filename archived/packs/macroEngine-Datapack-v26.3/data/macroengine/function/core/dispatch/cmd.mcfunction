# ─────────────────────────────────────────────────────────────────
# macroengine:core/dispatch/cmd [MACRO]
# AI-assisted: written with Claude (Anthropic). See CREDITS.md at the repo root.
# THE ONLY file in macroengine that executes a stored command string through
# the $$(cmd) line. It is the command-string twin of core/dispatch/exec, which
# is the only file that executes $function $(func).
#
# This file is NOT a gate and checks nothing. A caller that needs a check runs
# it BEFORE calling here (systems/cmd_gate/check), and the check must have run
# on the same macroengine:cmd_gate in.cmd that is passed below, so what was
# checked is exactly what runs.
#
# The command runs with the executor, position and rotation this function is
# called with. A caller that needs another executor sets it on the call:
#   $execute as $(player) at @s run function macroengine:core/dispatch/cmd with storage macroengine:cmd_gate in
#
# INPUT (macroengine:cmd_gate in): cmd -> the command string (no leading /)
# CALL:  function macroengine:core/dispatch/cmd with storage macroengine:cmd_gate in
# ─────────────────────────────────────────────────────────────────

$$(cmd)

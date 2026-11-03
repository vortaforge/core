# Ward test (CI only, see .github/workflows/ward.yml). Not valid vanilla syntax:
# `assert` and `await` come from the Ward mod, so Spyglass lint skips this folder.
# @max_ticks 20

# load.mcfunction must have created the divisor that tick.mcfunction uses.
assert score #const24000 db_gameday matches 24000

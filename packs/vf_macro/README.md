# VF Macro Backport

**VortaForge-compatible macro system for Minecraft 1.19.3–1.20.1**

Brings core macro features (`$(var)` substitution), `/return` simulation, and a built-in command execution engine to versions lacking native support—completely independent of external plugins or third-party engines.

## Installation

1. Drop the `vf-macro-backport` folder into your world's `datapacks/` directory.
2. Run `/reload` in the game.

---

## Quick Start

### 1. Macros (`$(key)` Substitution)

Define your arguments, set your template, and run:

```mcfunction
# 1. Set variables
data modify storage vf_macro:args name set value "Steve"
data modify storage vf_macro:args amount set value "5"

# 2. Set template
data modify storage vf_macro:in template set value "say Hello $(name), you received $(amount) diamonds!"

# 3. Run
function vf_macro:api/macro/run

```

For structured fragments (parts API):

```mcfunction
data modify storage vf_macro:in parts set value ["say Hello ",{key:"name"}," get ",{key:"amount"}," diamonds"]
function vf_macro:api/macro/parts

```

### 2. `/return` Simulation

Early-exit flag checks for functions:

```mcfunction
# Success return
function vf_macro:api/return/success

# Fail return
function vf_macro:api/return/fail

# Return with value (e.g., 5)
function vf_macro:api/return/value {value:5}

# Check on the caller side:
execute if score #vf_macro.returned vf_macro matches 1 run ...

```

### 3. Direct Command Execution

```mcfunction
data modify storage vf_macro:in Command set value "say Hello!"
function vf_macro:api/macro/run

```

---

## Storage & Namespaces

| Path | Purpose |
| --- | --- |
| `vf_macro:in` | Input data (template, command, parts list) |
| `vf_macro:args` | Macro arguments (`name`, `amount`, etc.) |
| `vf_macro:out` | Output and results |
| Scoreboard `vf_macro` | Status flags (`#vf_macro.returned`) |

## License

Unlicense — Public Domain.
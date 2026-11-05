# VF Macro v1.5.9

## Template placeholder expansion (no ostr)

On 1.16–1.19.3 Minecraft has no `set string`, so arbitrary in-string replace is impossible.
v1.5.9 expands **known template patterns** (e.g. `say Hello $(name)!`) into a resolved
string list and displays/runs via the same tellraw-join path that parts uses.

Supported examples:
- `say Hello $(name)!`
- `say Hello $(name)`
- `Hello $(name)!`
- `say $(name)`
- `say $(msg)`
- `say Hello $(player)!`
- `say $(amount)`

For fully arbitrary shapes use `api/macro/parts`.

## Parts API

Unchanged and separate from template.

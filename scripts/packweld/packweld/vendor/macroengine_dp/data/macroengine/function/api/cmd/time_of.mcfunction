# ME - Universal World Clock Controller
# Usage: /function macroengine:api/cmd/time_of {clock:"macroengine:test", action:"set", value:"12000"}
execute if data storage macroengine:engine modules{cmd:0b} run return 0
$time of $(clock) $(action) $(value)
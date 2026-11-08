# macroengine:core/internal/core/lib/queue/fire
execute if data storage macroengine:engine queue[0].func if data storage macroengine:engine queue[0].player run function macroengine:core/internal/core/lib/queue/run_func_as with storage macroengine:engine queue[0]
execute if data storage macroengine:engine queue[0].func unless data storage macroengine:engine queue[0].player run function macroengine:core/internal/core/lib/queue/run_func with storage macroengine:engine queue[0]
execute if data storage macroengine:engine queue[0].cmd if data storage macroengine:engine queue[0].player run function macroengine:core/internal/core/lib/queue/run_cmd_as with storage macroengine:engine queue[0]
execute if data storage macroengine:engine queue[0].cmd unless data storage macroengine:engine queue[0].player run function macroengine:core/internal/core/lib/queue/run_cmd with storage macroengine:engine queue[0]
data remove storage macroengine:engine queue[0]

"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[898],{30612:e=>{e.exports=JSON.parse('{"functions":[{"name":"Create.Schedule","desc":"Creates a new Schedule with jobs for each task in order.","params":[{"name":"Tasks","desc":"","lua_type":"{ Task }"},{"name":"Callbacks","desc":"","lua_type":"{ Before : (() -> true?)?, After : (() -> ())? }?"}],"returns":[{"desc":"","lua_type":"Schedule"}],"function_type":"static","source":{"line":88,"path":"src/init.lua"}},{"name":"Create.Calendar","desc":"Creates a new Calendar with Schedules in order.","params":[{"name":"Schedules","desc":"","lua_type":"{ Schedule }"},{"name":"Callbacks","desc":"","lua_type":"{ Before : (() -> true?)?, After : (() -> ())? }?"}],"returns":[{"desc":"","lua_type":"Calendar"}],"function_type":"static","source":{"line":117,"path":"src/init.lua"}},{"name":"Clear","desc":"Removes all jobs from a Schedule.","params":[{"name":"Schedule","desc":"","lua_type":"Schedule"}],"returns":[],"function_type":"static","source":{"line":134,"path":"src/init.lua"}},{"name":"Replace","desc":"Replaces the task of a job.","params":[{"name":"Job","desc":"","lua_type":"Job"},{"name":"Task","desc":"","lua_type":"Task"}],"returns":[],"function_type":"static","source":{"line":150,"path":"src/init.lua"}},{"name":"Find","desc":"Finds the first job with the given task in a Schedule.","params":[{"name":"Schedule","desc":"","lua_type":"Schedule"},{"name":"Task","desc":"","lua_type":"Task"}],"returns":[{"desc":"","lua_type":"Job?"}],"function_type":"static","source":{"line":166,"path":"src/init.lua"}},{"name":"Insert.Start","desc":"Inserts a new job at the start of a Schedule.","params":[{"name":"Schedule","desc":"","lua_type":"Schedule"},{"name":"Task","desc":"","lua_type":"Task"}],"returns":[{"desc":"","lua_type":"Job"}],"function_type":"static","source":{"line":185,"path":"src/init.lua"}},{"name":"Insert.End","desc":"Inserts a new job at the end of a Schedule.","params":[{"name":"Schedule","desc":"","lua_type":"Schedule"},{"name":"Task","desc":"","lua_type":"Task"}],"returns":[{"desc":"","lua_type":"Job"}],"function_type":"static","source":{"line":205,"path":"src/init.lua"}},{"name":"Insert.Before","desc":"Inserts a new job before a pre-existing job.","params":[{"name":"Job","desc":"","lua_type":"Job"},{"name":"Task","desc":"","lua_type":"Task"}],"returns":[{"desc":"","lua_type":"Job"}],"function_type":"static","source":{"line":225,"path":"src/init.lua"}},{"name":"Insert.After","desc":"Inserts a new job after a pre-existing job.","params":[{"name":"Job","desc":"","lua_type":"Job"},{"name":"Task","desc":"","lua_type":"Task"}],"returns":[{"desc":"","lua_type":"Job"}],"function_type":"static","source":{"line":248,"path":"src/init.lua"}},{"name":"Remove","desc":"Removes a job from its Schedule and sets its Schedule to nil.","params":[{"name":"Job","desc":"","lua_type":"Job"}],"returns":[],"function_type":"static","source":{"line":269,"path":"src/init.lua"}},{"name":"Fire.Schedule","desc":"Executes all jobs in a Schedule in order with the given arguments. If a job returns a non-nil value, the Schedule will stop executing.","params":[{"name":"Schedule","desc":"","lua_type":"Schedule"},{"name":"...","desc":"","lua_type":"any"}],"returns":[],"function_type":"static","source":{"line":287,"path":"src/init.lua"}},{"name":"Fire.Schedules","desc":"Executes all jobs in all Schedules in order with the given arguments. If a job returns a non-nil value, the Schedule will stop executing and it will move to the next Schedule.","params":[{"name":"Schedules","desc":"","lua_type":"{ Schedule }"},{"name":"...","desc":"","lua_type":"any"}],"returns":[],"function_type":"static","source":{"line":305,"path":"src/init.lua"}},{"name":"Fire.Job","desc":"Executes an individual job with the given arguments.","params":[{"name":"Job","desc":"","lua_type":"Job"},{"name":"...","desc":"","lua_type":"any"}],"returns":[{"desc":"","lua_type":"true?"}],"function_type":"static","source":{"line":324,"path":"src/init.lua"}},{"name":"Fire.Jobs","desc":"Executes a job and all jobs in its Schedule after in order with the given arguments. If a job returns a non-nil value, the jobs will stop executing.","params":[{"name":"Job","desc":"","lua_type":"Job"},{"name":"...","desc":"","lua_type":"any"}],"returns":[],"function_type":"static","source":{"line":337,"path":"src/init.lua"}},{"name":"Interval","desc":"Creates a new thread that will execute a callback every given number of seconds. If the callback returns a non-nil value, the thread will stop executing.","params":[{"name":"Seconds","desc":"","lua_type":"number"},{"name":"Callback","desc":"","lua_type":"() -> true?"}],"returns":[{"desc":"","lua_type":"thread"}],"function_type":"static","source":{"line":355,"path":"src/init.lua"}}],"properties":[],"types":[{"name":"Task","desc":"Executed by jobs.","lua_type":"(...any) -> true?","source":{"line":21,"path":"src/init.lua"}},{"name":"Job","desc":"Executes its tasks. If its Schedule is nil, it was removed from its Schedule and cannot be used again.","fields":[{"name":"Task","lua_type":"Task","desc":""},{"name":"Schedule","lua_type":"Schedule?","desc":""}],"source":{"line":31,"path":"src/init.lua"}},{"name":"Schedule","desc":"An ordered list of jobs. Before and after are called before and after the Schedule is executed. If Before returns true, the Schedule will not be executed.","fields":[{"name":"Jobs","lua_type":"{ Job }","desc":""},{"name":"Before","lua_type":"() -> true?","desc":""},{"name":"After","lua_type":"() -> ()","desc":""}],"source":{"line":45,"path":"src/init.lua"}},{"name":"Calendar","desc":"An ordered list of Schedules. Before and after are called before and after the Calendar is executed. If Before returns true, the Calendar will not be executed.","fields":[{"name":"Schedules","lua_type":"{ Schedule }","desc":""},{"name":"Before","lua_type":"() -> true?","desc":""},{"name":"After","lua_type":"() -> ()","desc":""}],"source":{"line":60,"path":"src/init.lua"}}],"name":"Sandwich","desc":"The simple Calendarr for Roblox.","source":{"line":14,"path":"src/init.lua"}}')}}]);
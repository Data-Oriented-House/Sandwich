"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[898],{30612:e=>{e.exports=JSON.parse('{"functions":[{"name":"schedule","desc":"Creates a new schedule that can be used to create jobs. Optionally takes in a `before` and `after` callback that will be called before and after each job is executed.","params":[{"name":"parameters","desc":"","lua_type":"{\\r\\n\\tbefore: (Job, ...any) -> ()?,\\r\\n\\tafter: (Job, ...any) -> ()?,\\r\\n}?"}],"returns":[{"desc":"","lua_type":"Schedule"}],"function_type":"static","source":{"line":41,"path":"src/init.lua"}},{"name":"interval","desc":"Creates a new thread that will execute a callback every given number of seconds. If the callback returns a non-nil value, the thread will stop executing.","params":[{"name":"seconds","desc":"","lua_type":"number"},{"name":"callback","desc":"","lua_type":"(T...) -> boolean?"},{"name":"...","desc":"","lua_type":"T..."}],"returns":[{"desc":"","lua_type":"thread"}],"function_type":"static","source":{"line":137,"path":"src/init.lua"}}],"properties":[],"types":[],"name":"Sandwich","desc":"The simple task scheduler for Roblox.","source":{"line":33,"path":"src/init.lua"}}')}}]);
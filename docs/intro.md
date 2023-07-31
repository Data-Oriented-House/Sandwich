---
sidebar_position: 1
---

# Introduction

## Why Would I Need Sandwich?

In Luau and Roblox there just aren't good ways to guarantee jobs run in a certain order. Roblox offers RunService, but uses an unfriendly priority system for RenderStepped that isn't even available for Heartbeat or other events, making ordering impossible on the Server. Luau just doesn't have any way to automatically order jobs at all.

## What Does Sandwich Do?

Sandwich simply lets you order jobs by specifying dependencies. Almost identical in concept to requiring modules to execute code. It uses topological sorting to order jobs, and then runs them in order. It also offers a way to execute code on intervals. That's it. Nothing crazy.

## How Do I Use Sandwich?

Very simple! You create Schedules and then add Jobs to them.

```lua
local newSchedule =  Sandwhich.schedule()

-- Runs concurrently with secondJob
local firstJob = newSchedule.job(function(text: string | number)
    print("First " .. text)
end)

-- Runs concurrently with firstJob
local secondJob = newSchedule.job(function(text: string | number)
    print("Second " .. text)
end)

-- Always runs after firstJob
local thirdJob = newSchedule.job(function(text: string | number)
    print("Third " .. text)
end, firstJob)
```

Then you can then start the schedule and all of the jobs will execute in topological order! Topological order in this case means dependencies will always be executed before the jobs that depend on them.

```lua
newSchedule.start("is running")
-- First is running
-- Second is running
-- Third is running
```

Now every time you want to run a schedule, you call the start method. This makes it incredibly easy to integrate with pre-existing schedulers like Roblox's RunService, or work with event-driven systems like user-input.

```lua
RunService.Heartbeat:Connect(newSchedule.start)
-- Second	0.016
-- First	0.016
-- Third	0.016

local renderSchedule = Sandwhich.schedule()
Runservice.RenderStepped:Connect(renderSchedule.start)
```
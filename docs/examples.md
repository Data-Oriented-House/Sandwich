# Examples

## Basic Example

```lua
local schedule = sandwich.schedule()

function schedule.before(job: Job, ...)
    print("Before", job, ...)
end

function schedule.after(job: Job, ...)
    print("After", job, ...)
end

local a = schedule.job(function(...)
    print("a", ...)
end)

local b = schedule.job(function(...)
    print("b", ...)
end)

local c = schedule.job(function(...)
    print("c", ...)
end, a, b)

local d = schedule.job(function(...)
    print("d", ...)
end, b, c)

local e = schedule.job(function(...)
    print("e", ...)
end, c)

local f = schedule.job(function(...)
    print("f", ...)
end, a, c, e)

schedule.start('1', '2')
```

## ECS Example

Let's use a fake ECS for example, since these are always fun to schedule because of their use of Systems.

```lua
local ECS = require(Some.Funny.ECS)

local schedule = sandwich.schedule {
	before = function(job: Job, deltaTime: number)
		print("Starting", job,  deltaTime)
	end,
}

local function updateAccelerations(deltaTime: number, entities)
	for entity in entities do
		entity.acceleration = (entity.target - entity.position) * deltaTime
	end
end

local function updateVelocities(deltaTime: number, entities)
	for entity in entities do
		entity.velocity += entity.acceleration * deltaTime
	end
end

local function updatePositions(deltaTime: number, entities)
	for entity in entities do
		entity.position += entity.velocity * deltaTime
	end
end

local accelerationSystem = schedule.job(function(deltaTime: number)
	print("Updating Acceleration", deltaTime)
	updateAccelerations(deltaTime, ECS.query("target", "position", "acceleration"))
end)

local velocitySystem = schedule.job(function(deltaTime: number)
	print("Updating Velocity", deltaTime)
	updateVelocities(deltaTime, ECS.query("velocity", "acceleration"))
end, accelerationSystem)

local positionSystem = schedule.job(function(deltaTime: number)
	print("Updating Position", deltaTime)
	updatePositions(deltaTime, ECS.query("position", "velocity"))
end, velocitySystem)

RunService.Heartbeat:Connect(schedule.start)
```
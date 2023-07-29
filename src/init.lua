--!strict

local function root() end

local function visit(schedule: Schedule, visited: { [Job]: true }, job: Job)
	if visited[job] then
		return
	end

	visited[job] = true

	for _, dependency in schedule.graph[job] do
		visit(schedule, visited, dependency)
	end

	if job ~= root then
		table.insert(schedule.jobs, 1, job)
	end
end

local function topologicalSort(schedule: Schedule)
	local visited = {}
	table.clear(schedule.jobs)

	visit(schedule, visited, root)
end

--[=[
	@class Sandwich

	The simple task scheduler for Roblox.
]=]
local Sandwich = {}

--[=[
	@within Sandwich
	@return Schedule

	Creates a new schedule that can be used to create jobs. Optionally takes in a `before` and `after` callback that will be called before and after each job is executed.
]=]
function Sandwich.schedule(parameters: {
	before: (Job, ...any) -> ()?,
	after: (Job, ...any) -> ()?,
}?)
	--[=[
		@class Schedule

		Schedules are used to create jobs that can be executed at a later time.
	]=]
	local schedule = {
		graph = { [root] = {} } :: { [Job]: { Job } },
		jobs = {} :: { Job },
		before = parameters and parameters.before,
		after = parameters and parameters.after,
	}

	--[=[
		@within Schedule

		Creates a new job that can be executed later by calling `Schedule.start`. Takes in other jobs as dependencies, which must be executed before this job is executed.

		```lua
		local schedule = Sandwich.new()

		local a = schedule.new(function(...) print("a", ...) end)
		local b = schedule.new(function(...) print("b", ...) end)
		local c = schedule.new(function(...) print("c", ...) end, a)
		local d = schedule.new(function(...) print("d", ...) end, a, b)
		local e = schedule.new(function(...) print("e", ...) end, c, d)
		local f = schedule.new(function(...) print("f", ...) end, a, e, b, c)
		```
	]=]
	function schedule.job(jobTask: (...any) -> (), ...: Job)
		local job = jobTask
		schedule.graph[job] = {}

		local dependencies = { ... }
		if #dependencies == 0 then
			table.insert(schedule.graph[root], job)
		else
			for _, dependency in dependencies do
				local nextJobs = schedule.graph[dependency]
				assert(
					nextJobs,
					'A dependency does not exist! You are passing in a job that was not created by this schedule, or you are not passing in a job at all.'
				)
				table.insert(nextJobs, job)
			end
		end

		topologicalSort(schedule)

		return job
	end

	--[=[
		@within Schedule

		Executes a schedule's tasks in topological order.

		```lua
		schedule.start("Hello, world!")

		-- b	Hello, world!
		-- a	Hello, world!
		-- d	Hello, world!
		-- c	Hello, world!
		-- e	Hello, world!
		-- f	Hello, world!
		```
	]=]
	function schedule.start(...: any)
		for _, job in schedule.jobs do
			local before = schedule.before
			if before then
				before(job, ...)
			end

			job(...)

			local after = schedule.after
			if after then
				after(job, ...)
			end
		end
	end

	return schedule
end

--[=[
	@within Sandwich
	@return thread

	Creates a new thread that will execute a callback every given number of seconds. If the callback returns a non-nil value, the thread will stop executing.
]=]
function Sandwich.interval<T...>(seconds: number, callback: (T...) -> boolean?, ...: T...)
	return task.spawn(function(...: T...)
		repeat
			task.wait(seconds)
		until callback(...)
	end, ...)
end


--[=[
	@within Schedule
	@interface Schedule
	.new (jobTask: (...: any) -> (), ...: Job) -> Job
	.start (...: any) -> ()
	.before (job: Job, ...: any) -> ()?
	.after (job: Job, ...: any) -> ()?
	.graph { [Job]: { Job } }
	.jobs { Job }
]=]
export type Schedule = typeof(Sandwich.schedule(...))

--[=[
	@within Schedule
	@type Job (...: any) -> ()
]=]
export type Job = typeof(Sandwich.schedule(...).job(...))

return Sandwich

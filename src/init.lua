--!strict

--[[
	Notes for features that may be useful in the future:
		Jobs have multiple tasks
		Jobs have execution counts, and can be removed after a certain number of executions
]]

local function root() end

--[=[
	@class Sandwich

	The simple task scheduler for Roblox.
]=]
local Sandwich = {}

function Sandwich.new(parameters: {
	debug: boolean?,
	before: ((Job, ...any) -> ())?,
	after: ((Job, ...any) -> ())?,
}?)
	--[=[
		@class Schedule

		Schedules are used to create jobs that can be executed at a later time.
	]=]
	local schedule = {
		jobs = { [root] = {} } :: { [Job]: { Job } },
		debug = not not (parameters and parameters.debug),
		before = parameters and parameters.before,
		after = parameters and parameters.after,
	}

	--[=[
		@within Schedule

		Creates a new job that can be executed later by calling `Schedule.fire`.
	]=]
	function schedule.new(jobTask: (...any) -> (), ...: Job)
		for _, job in {...} do
			local nextJobs = schedule.jobs[job]
			assert(nextJobs, "Job does not exist, you are passing in a job that was not created by this schedule, or you are not passing in a job at all.")
			table.insert(nextJobs, jobTask)
		end

		return jobTask
	end

	
	return schedule
end

--[=[
	@within Sandwich
	@type Job
]=]
export type Job = (...any) -> ()

--[=[
	@within Sandwich
	@type Schedule
]=]
export type Schedule = typeof(Sandwich.new())

return Sandwich

-- --[=[
-- 	@within Sandwich
-- 	@function Interval
-- 	@param Seconds number
-- 	@param Callback (...any) -> true?
-- 	@param ... any
-- 	@return thread

-- 	Creates a new thread that will execute a callback every given number of seconds. If the callback returns a non-nil value, the thread will stop executing.
-- ]=]
-- function Sandwich.Interval(Seconds : number, Callback : (...any) -> true?, ... : any) : thread
-- 	return task.spawn(function(... : any)
-- 		repeat task.wait(Seconds) until Callback()
-- 	end, ...)
-- end

-- return Sandwich

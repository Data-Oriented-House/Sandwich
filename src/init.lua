--!strict

--[[
	Notes for features that may be useful in the future:
		Jobs have multiple tasks
		Jobs have execution counts, and can be removed after a certain number of executions
]]

--[=[
	@class Sandwich

	The simple Calendarr for Roblox.
]=]

--[=[
	@within Sandwich
	@type Task (...any) -> true?

	Executed by jobs.
]=]
export type Task = (...any) -> true?

--[=[
	@within Sandwich
	@interface Job
	.Task Task
	.Schedule Schedule?

	Executes its tasks. If its Schedule is nil, it was removed from its Schedule and cannot be used again.
]=]
export type Job = {
	Task : Task,
	Schedule : Schedule?,
}

--[=[
	@within Sandwich
	@interface Schedule
	.Jobs { Job }
	.Before () -> true?
	.After () -> ()

	An ordered list of jobs. Before and after are called before and after the Schedule is executed. If Before returns true, the Schedule will not be executed.
]=]
export type Schedule = {
	Jobs : { Job },
	Before : () -> true?,
	After : () -> (),
}

--[=[
	@within Sandwich
	@interface Calendar
	.Schedules { Schedule }
	.Before () -> true?
	.After () -> ()

	An ordered list of Schedules. Before and after are called before and after the Calendar is executed. If Before returns true, the Calendar will not be executed.
]=]
export type Calendar = {
	Schedules : { Schedule },
	Before : () -> true?,
	After : () -> (),
}

type Callbacks = {
	Before : (() -> true?)?,
	After : (() -> ())?,
}


local JobNotInSchedule = "Job is not in a Schedule"
local function Nop() end

local Sandwich = {}

Sandwich.Create = {}

--[=[
	@within Sandwich
	@function Create.Schedule
	@param Tasks { Task }
	@param Callbacks { Before : (() -> true?)?, After : (() -> ())? }?
	@return Schedule

	From a list of tasks this creates a new Schedule by creating a new job for each task and adding it to the Schedule. The Schedule will store the jobs in the order they are given.
]=]
function Sandwich.Create.Schedule(Tasks : { Task }?, Callbacks : Callbacks?) : Schedule
	local Tasks = (Tasks or {}) :: { Task }
	local Callbacks = (Callbacks or {}) :: Callbacks

	local Schedule: Schedule = {
		Jobs = table.create(#Tasks),
		Before = Callbacks.Before or Nop,
		After = Callbacks.After or Nop,
	}

	for i, Task in Tasks do
		Schedule.Jobs[i] = {
			Task = Task,
			Schedule = Schedule,
		} :: Job
	end

	return Schedule
end

--[=[
	@within Sandwich
	@function Create.Calendar
	@param Schedules { Schedule }
	@param Callbacks { Before : (() -> true?)?, After : (() -> ())? }?
	@return Calendar

	This creates a new calendar from the given list of schedules. The calendar will store the schedules in the order they are given.
]=]
function Sandwich.Create.Calendar(Schedules : { Schedule }, Callbacks : Callbacks?) : Calendar
	local Callbacks = (Callbacks or {}) :: Callbacks

	return {
		Schedules = table.clone(Schedules),
		Before = Callbacks.Before or Nop,
		After = Callbacks.After or Nop,
	}
end

--[=[
	@within Sandwich
	@function Clear
	@param Schedule Schedule

	Removes all jobs from the given schedule.
]=]
function Sandwich.Clear(Schedule : Schedule)
	for _, Job in Schedule.Jobs do
		Job.Schedule = nil
	end

	table.clear(Schedule.Jobs)
end

--[=[
	@within Sandwich
	@function Replace
	@param Job Job
	@param Task Task
	@error "Job is not in a Schedule" -- The job was removed from its schedule before this call.

	Replaces the task of the given job with the given task.
]=]
function Sandwich.Replace(Job : Job, Task : Task)
	assert(Job.Schedule, JobNotInSchedule)
	local Schedule = Job.Schedule

	Schedule.Jobs[table.find(Schedule.Jobs, Job) :: number].Task = Task
end

--[=[
	@within Sandwich
	@function Find
	@param Schedule Schedule
	@param Task Task
	@return Job?

	Finds the first job with the given task in the given schedule.
]=]
function Sandwich.Find(Schedule : Schedule, Task : Task) : Job?
	for _, Job in Schedule.Jobs do
		if Job.Task == Task then return Job end
	end

	return nil
end

Sandwich.Insert = {}

--[=[
	@within Sandwich
	@function Insert.Start
	@param Schedule Schedule
	@param Task Task
	@return Job

	This inserts a new job with the given task at the start of the given schedule.
]=]
function Sandwich.Insert.Start(Schedule : Schedule, Task : Task) : Job
	local Job : Job = {
		Task = Task,
		Schedule = Schedule,
	}

	table.insert(Schedule.Jobs, 1, Job)

	return Job
end

--[=[
	@within Sandwich
	@function Insert.End
	@param Schedule Schedule
	@param Task Task
	@return Job

	This inserts a new job with the given task at the end of the given schedule.
]=]
function Sandwich.Insert.End(Schedule : Schedule, Task : Task) : Job
	local Job : Job = {
		Task = Task,
		Schedule = Schedule,
	}

	table.insert(Schedule.Jobs, Job)

	return Job
end

--[=[
	@within Sandwich
	@function Insert.Before
	@param Job Job
	@param Task Task
	@return Job
	@error "Job is not in a Schedule" -- The job was removed from its schedule before this call.

	This inserts a new job with the given task before the given job.
]=]
function Sandwich.Insert.Before(Job : Job, Task : Task) : Job
	assert(Job.Schedule, JobNotInSchedule)
	local Schedule = Job.Schedule

	local NewJob : Job = {
		Task = Task,
		Schedule = Schedule,
	}

	table.insert(Schedule.Jobs, table.find(Schedule.Jobs, Job) :: number, NewJob)

	return NewJob
end

--[=[
	@within Sandwich
	@function Insert.After
	@param Job Job
	@param Task Task
	@return Job
	@error "Job is not in a Schedule" -- The job was removed from its schedule before this call.

	This inserts a new job with the given task after the given job.
]=]
function Sandwich.Insert.After(Job : Job, Task : Task) : Job
	assert(Job.Schedule, JobNotInSchedule)
	local Schedule = Job.Schedule

	local NewJob : Job = {
		Task = Task,
		Schedule = Schedule,
	}

	table.insert(Schedule.Jobs, table.find(Schedule.Jobs, Job) :: number + 1, NewJob)

	return NewJob
end

--[=[
	@within Sandwich
	@function Remove
	@param Job Job
	@error "Job is not in a Schedule" -- The job was removed from its schedule before this call.

	This removes the given job from its schedule.
]=]
function Sandwich.Remove(Job : Job)
	assert(Job.Schedule, JobNotInSchedule)
	local Schedule = Job.Schedule

	table.remove(Schedule.Jobs, table.find(Schedule.Jobs, Job))
	Job.Schedule = nil
end

Sandwich.Fire = {}

--[=[
	@within Sandwich
	@function Fire.Schedule
	@param Schedule Schedule
	@param ... any

	Executes all jobs in a Schedule in order with the given arguments. If a job returns a non-nil value, the Schedule will stop executing.
]=]
function Sandwich.Fire.Schedule(Schedule : Schedule, ...: any)
	if Schedule.Before() then return end

	for _, Job in Schedule.Jobs do
		if Job.Task(...) == true then break end
	end

	Schedule.After()
end

--[=[
	@within Sandwich
	@function Fire.Schedules
	@param Schedules { Schedule }
	@param ... any

	Executes all jobs in all Schedules in order with the given arguments. If a job returns a non-nil value, the Schedule will stop executing and it will move to the next Schedule.
]=]
function Sandwich.Fire.Calendar(Calendar : Calendar, ...: any)
	if Calendar.Before() then return end

	for _, Schedule in Calendar.Schedules do
		Sandwich.Fire.Schedule(Schedule, ...)
	end

	Calendar.After()
end

--[=[
	@within Sandwich
	@function Fire.Job
	@param Job Job
	@param ... any
	@return true?
	@error "Job is not in a Schedule" -- The job was removed from its schedule before this call.

	Executes an individual job with the given arguments.
]=]
function Sandwich.Fire.Job(Job : Job, ...: any) : true?
	assert(Job.Schedule, JobNotInSchedule)
	return Job.Task(...)
end

--[=[
	@within Sandwich
	@function Fire.Jobs
	@param Job Job
	@param ... any
	@error "Job is not in a Schedule" -- The job was removed from its schedule before this call.

	Executes a job and all jobs in its Schedule after in order with the given arguments. If a job returns a non-nil value, the jobs will stop executing.
]=]
function Sandwich.Fire.Jobs(Job : Job, ...: any)
	assert(Job.Schedule, JobNotInSchedule)
	local Schedule = Job.Schedule

	for i = table.find(Schedule.Jobs, Job) :: number, #Schedule.Jobs do
		if Schedule.Jobs[i].Task(...) == true then break end
	end
end

--[=[
	@within Sandwich
	@function Interval
	@param Seconds number
	@param Callback () -> true?
	@return thread

	Creates a new thread that will execute a callback every given number of seconds. If the callback returns a non-nil value, the thread will stop executing.
]=]
function Sandwich.Interval(Seconds : number, Callback : () -> true?) : thread
	return task.spawn(function()
		repeat task.wait(Seconds) until Callback()
	end)
end

return Sandwich
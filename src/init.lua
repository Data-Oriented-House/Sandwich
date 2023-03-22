--!strict

--[[
	Notes for features that may be useful in the future:
		Jobs have multiple tasks
		Jobs have execution counts, and can be removed after a certain number of executions
]]

--[=[
	@class Sandwich

	The simple scheduler for Roblox.
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
	.Stream Stream?

	Executes its tasks. If its stream is nil, it was removed from a stream and cannot be used again.
]=]
export type Job = {
	Task : Task,
	Stream : Stream?,
}

--[=[
	@within Sandwich
	@interface Stream
	.Jobs { Job }
	.Before () -> true?
	.After () -> ()

	An ordered list of jobs. Before and after are called before and after the stream is executed. If Before returns true, the stream will not be executed.
]=]
export type Stream = {
	Jobs : { Job },
	Before : () -> true?,
	After : () -> (),
}

--[=[
	@within Sandwich
	@interface Schedule
	.Streams { Stream }
	.Before () -> true?
	.After () -> ()

	An ordered list of streams. Before and after are called before and after the schedule is executed. If Before returns true, the schedule will not be executed.
]=]
export type Schedule = {
	Streams : { Stream },
	Before : () -> true?,
	After : () -> (),
}

type Callbacks = {
	Before : (() -> true?)?,
	After : (() -> ())?,
}


local JobNotInStream = "Job is not in a stream"
local function Nop() end

local Sandwich = {}

Sandwich.Create = {}

--[=[
	@within Sandwich
	@function Create.Stream
	@param Tasks { Task }
	@param Callbacks { Before : (() -> true?)?, After : (() -> ())? }?
	@return Stream

	Creates a new stream with jobs for each task in order.
]=]
function Sandwich.Create.Stream(Tasks : { Task }, Callbacks : Callbacks?) : Stream
	local Callbacks = (Callbacks or {}) :: Callbacks

	local Stream: Stream = {
		Jobs = table.create(#Tasks),
		Before = Callbacks.Before or Nop,
		After = Callbacks.After or Nop,
	}

	for i, Task in Tasks do
		Stream.Jobs[i] = {
			Task = Task,
			Stream = Stream,
		} :: Job
	end

	return Stream
end

--[=[
	@within Sandwich
	@function Create.Schedule
	@param Streams { Stream }
	@param Callbacks { Before : (() -> true?)?, After : (() -> ())? }?
	@return Schedule

	Creates a new schedule with streams in order.
]=]
function Sandwich.Create.Schedule(Streams : { Stream }, Callbacks : Callbacks?) : Schedule
	local Callbacks = (Callbacks or {}) :: Callbacks

	return {
		Streams = table.clone(Streams),
		Before = Callbacks.Before or Nop,
		After = Callbacks.After or Nop,
	}
end

--[=[
	@within Sandwich
	@function Clear
	@param Stream Stream

	Removes all jobs from a stream.
]=]
function Sandwich.Clear(Stream : Stream)
	for _, Job in Stream.Jobs do
		Job.Stream = nil
	end

	table.clear(Stream.Jobs)
end

--[=[
	@within Sandwich
	@function Replace
	@param Job Job
	@param Task Task

	Replaces the task of a job.
]=]
function Sandwich.Replace(Job : Job, Task : Task)
	assert(Job.Stream, JobNotInStream)
	local Stream = Job.Stream

	Stream.Jobs[table.find(Stream.Jobs, Job) :: number].Task = Task
end

--[=[
	@within Sandwich
	@function Find
	@param Stream Stream
	@param Task Task
	@return Job?

	Finds the first job with the given task in a stream.
]=]
function Sandwich.Find(Stream : Stream, Task : Task) : Job?
	for _, Job in Stream.Jobs do
		if Job.Task == Task then return Job end
	end
end

Sandwich.Insert = {}

--[=[
	@within Sandwich
	@function Insert.Start
	@param Stream Stream
	@param Task Task
	@return Job

	Inserts a new job at the start of a stream.
]=]
function Sandwich.Insert.Start(Stream : Stream, Task : Task) : Job
	local Job : Job = {
		Task = Task,
		Stream = Stream,
	}

	table.insert(Stream.Jobs, 1, Job)

	return Job
end

--[=[
	@within Sandwich
	@function Insert.End
	@param Stream Stream
	@param Task Task
	@return Job

	Inserts a new job at the end of a stream.
]=]
function Sandwich.Insert.End(Stream : Stream, Task : Task) : Job
	local Job : Job = {
		Task = Task,
		Stream = Stream,
	}

	table.insert(Stream.Jobs, Job)

	return Job
end

--[=[
	@within Sandwich
	@function Insert.Before
	@param Job Job
	@param Task Task
	@return Job

	Inserts a new job before a pre-existing job.
]=]
function Sandwich.Insert.Before(Job : Job, Task : Task) : Job
	assert(Job.Stream, JobNotInStream)
	local Stream = Job.Stream

	local NewJob : Job = {
		Task = Task,
		Stream = Stream,
	}

	table.insert(Stream.Jobs, table.find(Stream.Jobs, Job) :: number, NewJob)

	return NewJob
end

--[=[
	@within Sandwich
	@function Insert.After
	@param Job Job
	@param Task Task
	@return Job

	Inserts a new job after a pre-existing job.
]=]
function Sandwich.Insert.After(Job : Job, Task : Task) : Job
	assert(Job.Stream, JobNotInStream)
	local Stream = Job.Stream

	local NewJob : Job = {
		Task = Task,
		Stream = Stream,
	}

	table.insert(Stream.Jobs, table.find(Stream.Jobs, Job) :: number + 1, NewJob)

	return NewJob
end

--[=[
	@within Sandwich
	@function Remove
	@param Job Job

	Removes a job from its stream and sets its stream to nil.
]=]
function Sandwich.Remove(Job : Job)
	assert(Job.Stream, JobNotInStream)
	local Stream = Job.Stream

	table.remove(Stream.Jobs, table.find(Stream.Jobs, Job))
	Job.Stream = nil
end

Sandwich.Fire = {}

--[=[
	@within Sandwich
	@function Fire.Stream
	@param Stream Stream
	@param ... any

	Executes all jobs in a stream in order with the given arguments. If a job returns a non-nil value, the stream will stop executing.
]=]
function Sandwich.Fire.Stream(Stream : Stream, ...: any)
	if Stream.Before() then return end

	for _, Job in Stream.Jobs do
		if Job.Task(...) == true then break end
	end

	Stream.After()
end

--[=[
	@within Sandwich
	@function Fire.Streams
	@param Streams { Stream }
	@param ... any

	Executes all jobs in all streams in order with the given arguments. If a job returns a non-nil value, the stream will stop executing and it will move to the next stream.
]=]
function Sandwich.Fire.Schedule(Schedule : Schedule, ...: any)
	if Schedule.On.Before() then return end

	for _, Stream in Schedule.Streams do
		Sandwich.Fire.Stream(Stream, ...)
	end

	Schedule.On.After()
end

--[=[
	@within Sandwich
	@function Fire.Job
	@param Job Job
	@param ... any
	@return true?

	Executes an individual job with the given arguments.
]=]
function Sandwich.Fire.Job(Job : Job, ...: any) : true?
	assert(Job.Stream, JobNotInStream)
	return Job.Task(...)
end

--[=[
	@within Sandwich
	@function Fire.Jobs
	@param Job Job
	@param ... any

	Executes a job and all jobs in its stream after in order with the given arguments. If a job returns a non-nil value, the jobs will stop executing.
]=]
function Sandwich.Fire.Jobs(Job : Job, ...: any)
	assert(Job.Stream, JobNotInStream)
	local Stream = Job.Stream

	for i = table.find(Stream.Jobs, Job) :: number, #Stream.Jobs do
		if Stream.Jobs[i].Task(...) == true then break end
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
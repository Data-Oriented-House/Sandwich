--!strict

export type Task = (...any) -> true?

export type Job = {
	Task : Task,
	Stream : Stream?,
}

export type Stream = {
	Jobs : { Job },
}

local JobNotInStream = "Job is not in a stream"

local Sandwich = {}

function Sandwich.Create(Tasks : { Task }?) : Stream
	local Tasks = (Tasks or {}) :: { Task }

	local Stream: Stream = {
		Jobs = table.create(#Tasks),
	}

	for i, Task in Tasks do
		Stream.Jobs[i] = {
			Task = Task,
			Stream = Stream,
		} :: Job
	end

	return Stream
end

function Sandwich.Clear(Stream : Stream)
	for _, Job in Stream.Jobs do
		Job.Stream = nil
	end

	table.clear(Stream.Jobs)
end

function Sandwich.Replace(Job : Job, Task : Task)
	assert(Job.Stream, JobNotInStream)
	local Stream = Job.Stream

	Stream.Jobs[table.find(Stream.Jobs, Job) :: number].Task = Task
end

function Sandwich.Find(Stream : Stream, Task : Task) : Job?
	for _, Job in Stream.Jobs do
		if Job.Task == Task then return Job end
	end
end

Sandwich.Insert = {}

function Sandwich.Insert.Start(Stream : Stream, Task : Task) : Job
	local Job : Job = {
		Task = Task,
		Stream = Stream,
	}

	table.insert(Stream.Jobs, 1, Job)

	return Job
end

function Sandwich.Insert.End(Stream : Stream, Task : Task) : Job
	local Job : Job = {
		Task = Task,
		Stream = Stream,
	}

	table.insert(Stream.Jobs, Job)

	return Job
end

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

function Sandwich.Remove(Job : Job)
	assert(Job.Stream, JobNotInStream)
	local Stream = Job.Stream

	table.remove(Stream.Jobs, table.find(Stream.Jobs, Job))
	Job.Stream = nil
end

Sandwich.Fire = {}

function Sandwich.Fire.Stream(Stream : Stream, ...: any)
	for _, Job in Stream.Jobs do
		if Job.Task(...) ~= nil then break end
	end
end

function Sandwich.Fire.Streams(Streams : { Stream }, ...: any)
	for _, Stream in Streams do
		Sandwich.Fire.Stream(Stream, ...)
	end
end

function Sandwich.Fire.Job(Job : Job, ...: any) : true?
	assert(Job.Stream, JobNotInStream)
	return Job.Task(...)
end

function Sandwich.Fire.Jobs(Job : Job, ...: any)
	assert(Job.Stream, JobNotInStream)
	local Stream = Job.Stream

	for i = table.find(Stream.Jobs, Job) :: number, #Stream.Jobs do
		if Stream.Jobs[i].Task(...) ~= nil then break end
	end
end

function Sandwich.Interval(Seconds : number, Callback : () -> true?) : thread
	return task.spawn(function()
		repeat task.wait(Seconds) until Callback()
	end)
end

return Sandwich
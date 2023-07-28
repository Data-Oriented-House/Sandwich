---
sidebar_position: 1
---

# Introduction

## Why Would I Need Sandwich?

In Luau and Roblox there just aren't good ways to guarantee jobs run in a certain order. Roblox offers RunService, but uses an unfriendly priority system for RenderStepped that isn't even available for Heartbeat or other events, making ordering impossible on the Server. Luau just doesn't have any way to automatically order jobs at all.

## What Does Sandwich Do?

Sandwich simply lets you order jobs by specifying dependencies. Almost identical in concept to requiring modules to execute code. It uses topological sorting to order jobs, and then runs them in order. It also offers a way to execute code on intervals. That's it. Nothing crazy.

## How Do I Use Sandwich?

You create `Schedules` and then add `Jobs` to them. You can then start the schedule and all of the jobs will execute in topological order. Every time you want to run a schedule, you start it again. This makes it incredibly easy to integrate with pre-existing schedulers like Roblox's RunService, or work with event-driven systems like user-input.
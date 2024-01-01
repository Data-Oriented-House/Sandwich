![Sandwich Logo](.moonwave/static/SandwichLogo.png)

# Why Does Sandwich Exist?

Roblox's RunService works great for most cases, but fails when you need to execute tasks in a specific order or at a specific time. RunService offers `:BindToRenderStepped()` which allows one to pass a priority, but the priority system is fragile and only works on the client because well, RenderStepped! Sandwich is able to define system chains that execute in a specific order, similar to Signals, but with the guarantee tasks execute in a defined order. It is able to scale to much more complicated setups with the use of Calendars, but allows you to only use more basic structures if you so choose without overhead.

# [Documentation](https://data-oriented-house.github.io/Sandwich/)

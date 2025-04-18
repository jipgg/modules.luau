--!strict
local Module = {}

local Multicast = require("./Multicast")
export type Multicast<Args...> = Multicast.Multicast<Args...>
Module.Multicast = Multicast

local Result = require("./Result")
export type Result<T, E> = Result.Result<T, E>
Module.Result = Result

return Module

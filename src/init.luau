--!strict
local module = {}

local multicast = require("./multicast")
export type multicast<Args...> = multicast.multicast<Args...>
module.multicast = multicast

local result = require("./result")
export type result<T, E> = result.result<T, E>
module.result = result

return module

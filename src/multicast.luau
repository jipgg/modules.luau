--!strict
export type error_handler_t = (err: string, caller: unknown) -> ()
export type multicast_fields<As...> = {
    functions: {(As...)->(...any)},
    error_handler: error_handler_t?,
}
export type multicast_index<As...> = {
    clear: (self: multicast<As...>) -> (),
    empty: (self: multicast<As...>) -> boolean,
    size: (self: multicast<As...>) -> number,
    as_function: (self: multicast<As...>) -> ((As...) -> ()),
    error_handler: error_handler_t,
}
export type multicast_metatable<As...> = {
    __index: multicast_index<As...>,
    __call: (self: multicast<As...>, As...) -> (),
    __add: (self: multicast<As...>, fn: (As...)->()) -> multicast<As...>,
    __sub: (self: multicast<As...>, fn: (As...)->()) -> multicast<As...>,
}
export type multicast<As...> = typeof(setmetatable(
    {} :: multicast_fields<As...>,
    {} :: multicast_metatable<As...>
))
local default_error_handler: error_handler_t
    = function(errmsg, entry) error(errmsg, 1) end

local index = {error_handler = default_error_handler} :: multicast_index<...any>
local metatable = {__index = index} :: multicast_metatable<...any>
local module = {}

function index:clear()
    table.clear(self.functions)
end
function index:empty()
    return #self.functions == 0
end
function index:size()
    return #self.functions
end
function index:as_function()
    return function(...) self(...) end
end
function metatable:__add(fn)
    table.insert(self.functions, fn)
    return self
end
function metatable:__sub(fn)
    local found = table.find(self.functions, fn)
    if found then
        table.remove(self.functions, found)
    end
    return self
end
function metatable:__call(...)
    for _, fn in self.functions do
        local ok, err = pcall(fn, ...)
        if not ok then
            (self.error_handler :: any)(err, fn)
        end
    end
end

function module.new<As...>(...: (As...)->()): multicast<As...>
    local self = {
        functions = {}
    }
    for i = 1, select('#', ...) do
        table.insert(self.functions, select(i, ...))
    end
    return setmetatable(self, metatable)
end

return module

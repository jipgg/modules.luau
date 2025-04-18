--!strict
export type error_handler_t = (err: string, caller: unknown) -> ()
export type Type<As...> = {
    functions: {(As...)->(...any)},
    error_handler: error_handler_t?,
    clear: (self: Multicast<As...>) -> (),
    empty: (self: Multicast<As...>) -> boolean,
    size: (self: Multicast<As...>) -> number,
    as_function: (self: Multicast<As...>) -> ((As...) -> ()),
}
export type Meta<As...> = {
    __call: (self: Multicast<As...>, As...) -> (),
    __add: (self: Multicast<As...>, fn: (As...)->()) -> Multicast<As...>,
    __sub: (self: Multicast<As...>, fn: (As...)->()) -> Multicast<As...>,
}
export type Multicast<As...> = typeof(setmetatable(
    {} :: Type<As...>,
    {} :: Meta<As...>
))
local Multicast = {} :: Type<...any> & Meta<...any>
(Multicast :: any).__index = Multicast

Multicast.error_handler = function(errmsg, entry)
    error(errmsg, 1)
end
function Multicast:clear()
    table.clear(self.functions)
end
function Multicast:empty()
    return #self.functions == 0
end
function Multicast:size()
    return #self.functions
end

function Multicast:__add(fn)
    table.insert(self.functions, fn)
    return self
end
function Multicast:__sub(fn)
    local found = table.find(self.functions, fn)
    if found then
        table.remove(self.functions, found)
    end
    return self
end
function Multicast:__call(...)
    for _, fn in self.functions do
        local ok, err = pcall(fn, ...)
        if not ok then
            (self.error_handler :: any)(err, fn)
        end
    end
end
function Multicast:as_function()
    return function(...) self(...) end
end

local Type = {}

function Type.new<As...>(...: (As...)->()): Multicast<As...>
    local self = {
        functions = {}
    }
    for i = 1, select('#', ...) do
        table.insert(self.functions, select(i, ...))
    end
    return setmetatable(self, Multicast) :: any
end
return Type

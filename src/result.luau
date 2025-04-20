--!strict
export type result_fields<T, E> = {
    UNION: T | E,
    HAS_VALUE: boolean,
}
export type result_index<T, E> = {
    has_error: (self: result<T, E>) -> boolean,
    and_then: (self: result<T, E>, fn: (T)->result<T, E>) -> result<T, E>,
    or_else: (self: result<T, E>, fn: (E)->result<T, E>) -> result<T, E>,
    match: <R>(self: result<T, E>, valfn: (T)->R, errfn: (E)->R) -> R,
    error: (self: result<T, E>) -> E,
    value: (self: result<T, E>) -> T,
    error_or: (self: result<T, E>, err: E) -> E,
    value_or: (self: result<T, E>, val: T) -> T,

}
export type result_metatable<T, E> = {
    __index: result_index<T, E>,
    __tostring: () -> string,
}
export type result<T = nil, E = string> = typeof(setmetatable(
    {} :: result_fields<T, E>,
    {} :: result_metatable<T, E>
))
local index = {} :: result_index<any, any>
local metatable = {__index = index} :: result_metatable<any, any>
local module = {}

function index:has_error()
    return not self.HAS_VALUE
end
function index:and_then(fn)
    return if self.HAS_VALUE then fn(self.UNION) else self
end
function index:or_else(fn)
    return if self.HAS_VALUE then self else fn(self.UNION)
end
function index:value()
    return if not self.HAS_VALUE then error("bad result access") else self.UNION
end
function index:error()
    return if self.HAS_VALUE then error("bad result access") else self.UNION
end
function index:value_or(val)
    return if self.HAS_VALUE then self.UNION else val
end
function index:error_or(err)
    return if self.HAS_VALUE then err else self.UNION
end
function index:match<R>(valfn, errfn)
    return if self.HAS_VALUE then valfn(self.UNION) else errfn(self.UNION)
end

function module.new<T, E>(val: T): result<T, E>
    return setmetatable({
        UNION = val,
        HAS_VALUE = true,
    }, metatable)
end
function module.error<T, E>(err: E): result<T, E>
    return setmetatable({
        UNION = err,
        HAS_VALUE = false,
    }, metatable)
end
function module.transform<From, To, E>(v: result<From, E>, fn: (From)->To): result<To, E>
    return if v.HAS_VALUE
    then module.new(fn(v.UNION :: From))
    else module.error(v.UNION :: E)
end
function module.transform_error<T, From, To>(v: result<T, From>, fn: (From)->To): result<T, To>
    return if v.HAS_VALUE
    then module.new(v.UNION :: T)
    else module.error(fn(v.UNION :: From))
end
function module.wrap<T, A...>(fn: (A...) -> T): result<T, string>
    local success, data = pcall(fn)
    return if success
    then module.new(data)
    else module.error(data :: any)
end
return module

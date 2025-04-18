--!strict
export type Type<T = nil, E = string> = {
    UNION: T | E,
    HAS_VALUE: boolean,
    has_error: (self: Result<T, E>) -> boolean,
    and_then: (self: Result<T, E>, fn: (T)->Result<T, E>) -> Result<T, E>,
    or_else: (self: Result<T, E>, fn: (T)->Result<T, E>) -> Result<T, E>,
    match: <R>(self: Result<T, E>, valfn: (T)->R, errfn: (E)->R) -> R,
    error: (self: Result<T, E>) -> E,
    value: (self: Result<T, E>) -> T,
    error_or: (self: Result<T, E>, err: E) -> E,
    value_or: (self: Result<T, E>, val: T) -> T,
}
export type Meta<T, E> = {

}
export type Result<T = nil, E = string> = typeof(setmetatable(
{} :: Type<T, E>, {}))
local Result = {} :: Type<any, any>
(Result :: any).__index = Result

function Result:has_error()
    return not self.HAS_VALUE
end
function Result:and_then(fn)
    return if self.HAS_VALUE then fn(self.UNION) else self
end
function Result:or_else(fn)
    return if self.HAS_VALUE then self else fn(self.UNION)
end
function Result:value()
    return if not self.HAS_VALUE then error("bad result access") else self.UNION
end
function Result:error()
    return if self.HAS_VALUE then error("bad result access") else self.UNION
end
function Result:value_or(val)
    return if self.HAS_VALUE then self.UNION else val
end
function Result:error_or(err)
    return if self.HAS_VALUE then err else self.UNION
end
function Result:match<R>(valfn, errfn)
    return if self.HAS_VALUE then valfn(self.UNION) else errfn(self.UNION)
end
local Type = {}
function Type.new<T, E>(val: T): Result<T, E>
    return setmetatable({
        UNION = val,
        HAS_VALUE = true,
    }, Result) :: any
end
function Type.error<T, E>(err: E): Result<T, E>
    return setmetatable({
        UNION = err,
        HAS_VALUE = false,
    }, Result) :: any
end
function Type.transform<From, To, E>(v: Result<From, E>, fn: (From)->To): Result<To, E>
    return if v.HAS_VALUE
    then Type.new(fn(v.UNION :: From))
    else Type.error(v.UNION :: E)
end
function Type.transform_error<T, From, To>(v: Result<T, From>, fn: (From)->To): Result<T, To>
    return if v.HAS_VALUE
    then Type.new(v.UNION :: T)
    else Type.error(fn(v.UNION :: From))
end
function Type.wrap<T, A...>(fn: (A...) -> T): Result<T, string>
    local success, data = pcall(fn)
    return if success
    then Type.new(data)
    else Type.error(data :: any)
end
return Type

--!strict
local Result = require('@modules/Result')
type Result<T, E> = Result.Result<T, E>
local Multicast = require('@modules/Multicast')
local do_something = Multicast.new(function(a: number)
    print(`something {a}`)
end)
local function some_action(a: number) print(`some action {a}`) end
do_something(do_something:size())
do_something += some_action
do_something(do_something:size())
do_something -= some_action
do_something(do_something:size())

local function some_function(): Result<number, string>
    local r = math.random(0, 1) == 1
    return if r then Result.error("some error") else Result.new(123)
end
local message = some_function():match(
    function(val) return `success {val}` end,
    function(err) return `error {err}` end
)
print(`message: {message}`)

local value = some_function():and_then(function(val)
    print(`no error: {val}`)
    return Result.new(val)
end):or_else(function(err)
    print(`error occured: {err}. using fallback value`)
    return Result.new(456)
end):value_or(0)
print(`value is {value}`)

local res = Result.new("aeee")
Result.transform(res, function(a0: string) return string.pack(a0)  end)

--!strict
local m = require('@modules')
local do_something = m.multicast.new(function(a: number)
    print(`something {a}`)
end)
local some_action: (number)->() = function(a)
    print(`some action {a}`)
end
do_something(do_something:size())
do_something += some_action
do_something(do_something:size())
do_something -= some_action
do_something(do_something:size())

type result_t = m.result<number, string>
local some_function: ()->result_t = function()
    local r = math.random(0, 1) == 1
    return if r then m.result.error("some error") else m.result.new(123)
end
local message = some_function():match(
    function(val) return `success {val}` end,
    function(err) return `error {err}` end
)
print(`message: {message}`)

local value = some_function():and_then(function(val)
    print(`no error: {val}`)
    return m.result.new(val)
end):or_else(function(err)
    print(`error occured: {err}. using fallback value`)
    return m.result.new(456)
end):value_or(0)
print(`value is {value}`)

local res = m.result.new("aeee")
m.result.transform(res, function(a0: string) return string.pack(a0)  end)

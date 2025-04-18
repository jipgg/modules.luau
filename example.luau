--!strict
local Result = require('@modules/Result')
local Multicast = require('@modules/Multicast')
local mf = Multicast.new(function(a: number)
end)
mf += function(a: number)
    return ""
end

local res = Result.new("aeee")
Result.transform(res, function(a0: string) return string.pack(a0)  end)

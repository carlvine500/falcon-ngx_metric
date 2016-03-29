
local dict = ngx.shared.result_dict
local counter = require "ngx_metric.counter"
local chunkhisto = require "ngx_metric.chunk_histogram"

local function output(t)
    for k, v in pairs(t) do
        ngx.say(k .. "|" .. v)
    end
end

-- ngx.say("raw dict:")
-- for _, k in pairs(dict:get_keys()) do
--     ngx.say(k .. "|" .. dict:get(k))
-- end
-- ngx.say("\n\ncalc dict:")

output(counter.get_snapshot(dict))
output(chunkhisto.get_snapshot(dict))

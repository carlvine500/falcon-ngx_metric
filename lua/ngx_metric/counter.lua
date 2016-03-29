-- Copyright (C) Guy Cheung
--
local shared = ngx.shared
local log = ngx.log
local ERR = ngx.ERR

local util = require "ngx_metric.util"

local PREFIX = "counter."

local _M = { _VERSION = '0.0.1' }

function _M.add(dict, metric, value)
    util.dict_safe_incr(dict, PREFIX .. metric, tonumber(value))
end

function _M.get_snapshot(dict)
    local keys = util.dict_get_keys(dict, PREFIX)

    local res = {}
    for _, k in pairs(keys) do
        res[util.str_trim_prefix(k, PREFIX)] = dict:get(k)
        dict:delete(k)
    end

    return res
end

return _M

-- Copyright (C) Guy Cheung
--
local shared = ngx.shared
local log = ngx.log
local ERR = ngx.ERR

local util = require "ngx_metric.util"

local PREFIX_SUM = "avg.sum."
local PREFIX_LEN = "avg.len."

local _M = { _VERSION = '0.0.1' }

function _M.add(dict, metric, value)
    local ks = PREFIX_SUM .. metric
    local kl = PREFIX_LEN .. metric
    util.dict_safe_incr(dict, ks, tonumber(value))
    util.dict_safe_incr(dict, kl, 1)
end

function _M.get_snapshot(dict)
    local keys = util.dict_get_keys(dict, PREFIX_SUM)
    local res = {}

    for _, ks in pairs(keys) do
        local k = util.str_trim_prefix(ks, PREFIX_SUM)
        local kl = PREFIX_LEN .. k

        local l = tonumber(dict:get(kl))
        if l ~= nil and l ~= 0 then
            res[k] = tonumber(dict:get(ks)) / l

            dict:delete(ks)
            dict:delete(kl)
        end
    end

    return res
end

return _M

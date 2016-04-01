-- Copyright (C) Guy Cheung
--
local log = ngx.log
local ERR = ngx.ERR

local util = require "ngx_metric.util"
local histogram = require "ngx_metric.histogram"
local avg = require "ngx_metric.avg"

local CHUNK_SIZE = 500
local PERCENTILES = {50, 75, 95, 99}

local CHUNK_PREFIX_RAWVAL = "chisto.rawval."
local CHUNK_PREFIX_RAWLEN = "chisto.rawlen."

local _M = { _VERSION = '0.0.1' }

local function seperate_metric(metric)
    local pos, _ = string.find(metric, "|")
    if pos == nil then
        return metric, ""
    else
        return string.sub(metric, 1, pos-1), string.sub(metric, pos, -1)
    end
end

local function add_raw_point(dict, metric, value)
    local valmetric = CHUNK_PREFIX_RAWVAL .. metric
    local list = dict:get(valmetric) or ""
    list = list .. value .. ","
    util.dict_safe_set(dict, valmetric, list)

    local lenmetric = CHUNK_PREFIX_RAWLEN .. metric
    util.dict_safe_incr(dict, lenmetric, 1)
end

local function is_need_sample_points(dict, metric)
    local length = tonumber(dict:get(CHUNK_PREFIX_RAWLEN .. metric) or 0)
    return length >= CHUNK_SIZE
end

local function sample_points(dict, metric)
    local lenmetric = CHUNK_PREFIX_RAWLEN .. metric
    local valmetric = CHUNK_PREFIX_RAWVAL .. metric

    local list = dict:get(valmetric) or ""
    dict:delete(valmetric)
    dict:delete(lenmetric)

    local histo = histogram:new(list)
    local metric_a, metric_b = seperate_metric(metric)
    for _, v in ipairs(PERCENTILES) do
        avg.add(dict, metric_a .. "_" .. v .. "th" .. metric_b, histo:percentile(v / 100.0))
    end
end

local function sample_all_points(dict)
    local keys = util.dict_get_keys(dict, CHUNK_PREFIX_RAWVAL)
    for _, k in pairs(keys) do
        sample_points(dict, util.str_trim_prefix(k, CHUNK_PREFIX_RAWVAL))
    end
end

function _M.add(dict, metric, value)

    add_raw_point(dict, metric, value)

    if is_need_sample_points(dict, metric) then
        sample_points(dict, metric)
    end

end

function _M.get_snapshot(dict)
    sample_all_points(dict)
    return avg.get_snapshot(dict)
end

return _M

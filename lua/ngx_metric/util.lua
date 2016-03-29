-- Copyright (C) Guy Cheung
--
local log = ngx.log
local ERR = ngx.ERR

local _M = { _VERSION = '0.0.1' }

function _M.dict_get_keys(dict, prefix)
    local keys = dict:get_keys()
    local res = {}

    for _, k in pairs(keys) do
        if _M.str_startwith(k, prefix) then
            table.insert(res, k)
        end
    end

    return res
end

function _M.dict_safe_set(dict, metric, value)
    local ok, err = dict:safe_set(metric, value)
    if err == "no memory" then
        log(ERR, "no memory for ngx_metric set kv: " .. metric .. ":" .. value)
    end
end

function _M.dict_safe_incr(dict, metric, value)
    if tonumber(value) == nil then
        return
    end

    local newval, err = dict:incr(metric, value)
    if not newval and err == "not found" then
        local ok, err = dict:safe_add(metric, value)
        if err == "exists" then
            dict:incr(metric, value)
        elseif err == "no memory" then
            log(ERR, "no memory for ngx_metric add kv: " .. metric .. ":" .. value)
        end
    end
end

function _M.str_split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end

function _M.str_trim_prefix(str, prefix)
    local len = string.len(prefix)
    if string.sub(str, 1, len) == prefix then
        return string.sub(str, len+1, -1)
    end
    return str
end

function _M.str_startwith(str, start)
    return string.sub(str, 1, string.len(start)) == start
end

return _M

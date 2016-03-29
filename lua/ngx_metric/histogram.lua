-- Copyright (C) Guy Cheung
--
local log = ngx.log
local ERR = ngx.ERR
local util = require "ngx_metric.util"

local _M = { _VERSION = '0.0.1' }
local mt = { __index = _M }

function _M.new(_, values)
    local self = {
        values = {},
        dirty = true,
    }

    local histo = setmetatable(self, mt)
    histo:add(values)

    return histo
end

function _M.add(self, values)
    if type(values) == "string" then
        values = util.str_split(values, ",")
    end

    if type(values) == "table" then
        for _, v in ipairs(values) do
            table.insert(self.values, tonumber(v))
        end

    elseif type(values) == "number" then
        table.insert(self.values, v)

    else
        log(ERR, "unknown value type " .. type(values))

    end

    self.dirty = true
end

function _M.calc(self)
    if not self.dirty or table.getn(self.values) == 0 then
        return
    end

    table.sort(self.values)
    self.dirty = false
end

function _M.percentile(self, percentile)
    if self.dirty then
        self:calc()
    end

    local pos = math.min(math.ceil(table.getn(self.values) * percentile), table.getn(self.values))
    return self.values[pos]
end

return _M

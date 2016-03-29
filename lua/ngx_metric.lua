-- Copyright (C) Guy Cheung
--

local ngx_metric = require "ngx_metric.ngx_metric"

---- result_dict记录最终采集到的数据
local dict = ngx.shared.result_dict
local item_sep = "|"

---- url 截断长度
local uri_section_len = tonumber(ngx.var.ngx_metric_uri_truncation_len)
if uri_section_len == nil then
    uri_section_len = 3
end

ngx_metric = ngx_metric:new(dict, item_sep, uri_section_len)
ngx_metric:record()


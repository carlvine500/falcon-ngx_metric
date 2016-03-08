# Introduction
===========================

ngx_metric(Nginx-Metric) -- Open-Falcon的Nginx Web Server请求数据采集工具，主要包括流量大小、响应时间、异常请求统计等。

# 环境需求
--------------------------

System: Linux
Python: >= 2.6
Nginx+Lua

# 主要逻辑
--------------------------

通过lua nginx module的`log_by_lua_file`实时记录nginx请求数据，通过外部python脚本定时获取数据解析为Open-Falcon支持的数据类型。

# 汇报字段
--------------------------

|key|tag|type|note|
|---|---|---|---|
|query_count|api|GAUGE|nginx 正常请求(status code < 400)数量|
|error_count|api,errcode|GAUGE|nginx 异常请求(status code >= 400)数量|
|error_rate|api|GAUGE|nginx 异常请求比例|
|latency_{50,75,95,99}th|api|GAUGE|nginx 请求平均响应时间，按百分位统计|
|upstream_contacts|api|GAUGE|nginx upstream 请求次数|
|upstream_latency_{50,75,95,99}th|api|GAUGE|nginx upstream平均响应时间，按百分位统计|

> api tag: 即nginx request uri，各统计项按照uri区分。当api为保留字`__serv__`时，代表nginx所有请求的综合统计
> error_count、upstream统计项根据实际情况，如果没有则不会输出

# 使用方法
------------------------

---- utils function
function str_split(inputstr, sep)
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

function cut_uri(uri, section_len)
    local uri_a = str_split(uri, "/")
    local res = ""
    for i = 1, math.min(section_len, #uri_a) do
        res = res .. "/" .. uri_a[i]
    end
    return res
end

function req_sign(t)
    return t .. item_sep .. ngx.var.server_name .. item_sep .. cutted_uri
end

function safe_incr(metric, value)
    local newval, err = result_dict:incr(metric, value)
    if not newval and err == "not found" then
        ok, err = result_dict:safe_add(metric, value)
        if err == "exists" then
            result_dict:incr(metric, value)
        elseif err == "no memory" then
            ngx.log(ngx.ERR, "no memory for ngx_metric add kv: " .. metric .. ":" .. value)
        end
    end
end

function safe_set(metric, value)
    ok, err = result_dict:safe_set(metric, value)
    if err == "no memory" then
        ngx.log(ngx.ERR, "no memory for ngx_metric set kv: " .. metric .. ":" .. value)
    end
end

---- 请求次数统计, counter类型
function query_count()

    local metric = req_sign("query_count")
    safe_incr(metric, 1)

end

-- latency
function latency()

    local metric = req_sign("latency")
    local latency = tonumber(ngx.var.request_time) or 0

    local latency_list = result_dict:get(metric) or ""
    latency_list = latency_list..latency..","

    safe_set(metric, latency_list)

end

-- http error status stat
function err_count()

    local status_code = tonumber(ngx.var.status)

    if status_code >= 400 then
        local metric_err_qc = req_sign("err_count")

-- 取消err_count总数汇报
--        local newval, err = result_dict:incr(metric_err_qc, 1)
--        if not newval and err == "not found" then
--            result_dict:add(metric_err_qc, 1)
--        end

        local metric_err_detail = metric_err_qc.."|"..status_code
        safe_incr(metric_err_detail, 1)
    end

end

---- upstream_time统计, timer类型
function upstream_time()

    local upstream_response_time_s = ngx.var.upstream_response_time or ""
    upstream_response_time_s = string.gsub(string.gsub(upstream_response_time_s, ":", ","), " ", "")

    if upstream_response_time_s == "" then
        return
    end

    local resp_time_arr = str_split(upstream_response_time_s, ",")

    local metric = req_sign("upstream_contacts")
    safe_incr(metric, 1)

    local duration = 0.0
    for _, t in pairs(resp_time_arr) do
        if tonumber(t) then
            duration = duration + tonumber(t)
        end
    end

    local metric_upstream_latency = req_sign("upstream_latency")
    local latency_list = result_dict:get(metric_upstream_latency) or ""
    latency_list = latency_list..duration..","
    safe_set(metric_upstream_latency, latency_list)

end

---- result_dict记录最终采集到的数据
result_dict = ngx.shared.result_dict

---- url 截断长度
uri_section_len = tonumber(ngx.var.ngx_metric_uri_truncation_len)
if uri_section_len == nil then
    uri_section_len = 3
end

item_sep = "|"

---- 总体统计
function main()

    cutted_uri = cut_uri(ngx.var.uri, uri_section_len)

    local status_code = tonumber(ngx.var.status)
    if status_code >= 400 then
        err_count()
    else
        query_count()
    end

    latency()
    upstream_time()

end

main()


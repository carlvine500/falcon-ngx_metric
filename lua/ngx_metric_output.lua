
result_dict = ngx.shared.result_dict

for _, k in pairs(result_dict:get_keys()) do
    local v = result_dict:get(k)
    ngx.say(k .. "|" .. v)

    result_dict:delete(k)
end

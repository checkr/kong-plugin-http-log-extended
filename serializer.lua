local _M = {}

function _M.serialize(ngx, req_body, res_body) 
  local authenticated_entity
  if ngx.ctx.authenticated_credential ~= nil then
    authenticated_entity = {
      id = ngx.ctx.authenticated_credential.id,
      consumer_id = ngx.ctx.authenticated_credential.consumer_id
    }
  end

  local request_uri = ngx.var.request_uri or ""

  return {
    request = {
      uri = request_uri,
      url = ngx.var.scheme .. "://" .. ngx.var.host .. ":" .. ngx.var.server_port .. request_uri,
      querystring = ngx.req.get_uri_args(), 
      method = ngx.req.get_method(),
      headers = ngx.req.get_headers(),
      size = ngx.var.request_length,
      body = req_body or {}
    },
    response = {
      status = ngx.status,
      headers = ngx.req.get_headers(),
      size = ngx.var.bytes_sent,
      body = res_body or {}
    }, 
    latencies = {
      kong = (ngx.ctx.KONG_ACCESS_TIME or 0) +
             (ngx.ctx.KONG_RECEIVE_TIME or 0),
      proxy = ngx.ctx.KONG_WAITING_TIME or -1,
      request = ngx.var.request_time * 1000
    },
    authenticated_entity = authenticated_entity,
    api = ngx.ctx.api,
    client_ip = ngx.var.remote_addr,
    started_at = ngx.req.start_time() * 1000
  }
end 

return _M 
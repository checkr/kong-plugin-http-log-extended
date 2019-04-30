return {
  fields = {
    http_endpoint = { required = true, type = "url" },
    method = { type = "string", default = "POST", one_of = { "POST", "PUT", "PATCH" }, },
    content_type = { type = "string", default = "application/json", one_of = { "application/json" }, },
    timeout = { type = "number", default = 5000 },
    keepalive = { type = "number", default = 60000 },
    retry_count = { type = "integer", default = 5 },
    queue_size = { type = "integer", default = 1 },
    flush_timeout = { type = "number", default = 2 },
    log_request_body = { type = "boolean", default = true },
    log_response_body = { type = "boolean", default = true },
    sync_log = { type = "boolean", default = true },
  }
}

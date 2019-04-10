local BasePlugin = require "kong.plugins.base_plugin"
local basic_serializer = require "kong.plugins.http-log-extended.serializer"
local LuaProducer = require "kong.plugins.http-log-extended.lua_producer"
local JSONProducer = require "kong.plugins.http-log-extended.json_producer"
local Sender = require "kong.plugins.http-log-extended.sender"
local Buffer = require "kong.plugins.http-log-extended.buffer"
local cjson = require "cjson"

local cjson_encode = cjson.encode
local ERR = ngx.ERR

local HttpLogExtendedHandler = BasePlugin:extend()

HttpLogExtendedHandler.PRIORITY = 4
HttpLogExtendedHandler.VERSION = "1.1"

local function get_request_body()
  ngx.req.read_body()
  return ngx.req.get_body_data()
end

local buffers = {}

function HttpLogExtendedHandler:new()
  name = name or "http-log-extended"
  HttpLogExtendedHandler.super.new(self, name)
  self.ngx_log = ngx.log
  self.name = name
end

function HttpLogExtendedHandler:access(conf)
  HttpLogExtendedHandler.super.access(self)
  ngx.ctx.http_log_extended = { req_body = "", res_body = "" }

  if (conf.log_request_body) then
    ngx.ctx.http_log_extended = { req_body = get_request_body() }
  end
end

function HttpLogExtendedHandler:body_filter(conf)
  HttpLogExtendedHandler.super.body_filter(self)
  if (conf.log_response_body) then
    local chunk = ngx.arg[1]
    local ctx = ngx.ctx
    local res_body = ctx.http_log_extended and ctx.http_log_extended.res_body or ""
    res_body = res_body .. (chunk or "")
    ctx.http_log_extended.res_body = res_body
  end
end

-- serializes context data into an html message body.
-- @param `ngx` The context table for the request being logged
-- @param `conf` plugin configuration table, holds http endpoint details
-- @return html body as string
function HttpLogExtendedHandler:serialize(ngx)
  return cjson.encode(basic_serializer.serialize(ngx))
end

function HttpLogExtendedHandler:log(conf)
  HttpLogExtendedHandler.super.log(self)

  local route_id = conf.route_id or "global"
  local buf = buffers[route_id]

  if not buf then
    if conf.queue_size == nil then
      conf.queue_size = 1
    end

    -- base delay between batched sends
    conf.send_delay = 0

    local buffer_producer
    -- If using a queue, produce messages into a JSON array,
    -- otherwise keep it as a 1-entry Lua array which will
    -- result in a backward-compatible single-object HTTP request.
    if conf.queue_size > 1 then
      buffer_producer = JSONProducer.new(true)
    else
      buffer_producer = LuaProducer.new()
    end

    local err
    buf, err = Buffer.new(self.name, conf, buffer_producer, Sender.new(conf, self.ngx_log), self.ngx_log)
    if not buf then
      self.ngx_log(ERR, "could not create buffer: ", err)
      return
    end
    buffers[route_id] = buf
  end

  -- This can be simplified if we don't expect third-party plugins to
  -- "subclass" this plugin.
  buf:add_entry(self:serialize(ngx, conf))

end

return HttpLogExtendedHandler

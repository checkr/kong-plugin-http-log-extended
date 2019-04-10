package = "kong-plugin-http-log-extended"
version = "1.1-1"
supported_platforms = {"linux", "macosx"}

local pluginName = package:match("^kong%-plugin%-(.+)$")

source = {
  url = "git://github.com/checkr/kong-http-log-extended",
  tag = "1.1"
}

description = {
  summary = "Add Request & Response Body log options in http-log",
  license = "MIT",
}

dependencies = {
}

build = {
  type = "builtin",
  modules = {
    ["kong.plugins."..pluginName..".handler"] = "kong/plugins/"..pluginName.."/handler.lua",
    ["kong.plugins."..pluginName..".schema"] = "kong/plugins/"..pluginName.."/schema.lua",
    ["kong.plugins."..pluginName..".serializer"] = "kong/plugins/"..pluginName.."/serializer.lua",
    ["kong.plugins."..pluginName..".sender"] = "kong/plugins/"..pluginName.."/sender.lua",
    ["kong.plugins."..pluginName..".buffer"] = "kong/plugins/"..pluginName.."/buffer.lua",
    ["kong.plugins."..pluginName..".json_producer"] = "kong/plugins/"..pluginName.."/json_producer.lua",
    ["kong.plugins."..pluginName..".lua_producer"] = "kong/plugins/"..pluginName.."/lua_producer.lua",
  }
}

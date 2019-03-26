package = "kong-plugin-http-log-extended"
version = "1.0-1"
supported_platforms = {"linux", "macosx"}

local pluginName = package:match("^kong%-plugin%-(.+)$")

source = {
  url = "git://github.com/checkr/kong-http-log-extended",
  tag = "0.1.1"
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
  }
}

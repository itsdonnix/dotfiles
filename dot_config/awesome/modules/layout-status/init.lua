local awful = require("awful")

-- Default output file path
local output_file = "/tmp/awesomewm-layout-status"

-- Map layout to icon and abbreviation
local icons = {
  tile                = "󰖯 TILE",
  tileleft            = "󰕮 TLEF",
  tiletop             = "󰖾 TTOP",
  fair                = "󰕰 FAIR",
  ["fair.horizontal"] = "󰘧 FHOR",
  spiral              = "󰘚 SPIR",
  dwindle             = "󰧑 DWIN",
  max                 = "󰊓 MAX",
  fullscreen          = "󰖳 FULL",
  floating            = "󰈼 FLOT",
  magnifier           = "󰒱 MAGN",
  cornernw            = "󱉶 CNW",
}

local function get_layout_output(name)
  if icons[name] then
    return icons[name]
  else
    -- fallback icon + first 4 uppercase chars of name
    return "󰘥 " .. (name:sub(1, 4):upper())
  end
end

local function init_mkfifo()
  awful.spawn.with_shell("[ -p " .. output_file .. " ] || mkfifo " .. output_file)
end

local function write_layout_info_to_fifo(layout)
  local name = awful.layout.getname(layout)
  local output = get_layout_output(name)
  awful.spawn.with_shell("echo '" .. output .. "' > " .. output_file)
end

-- Function to load configuration
local function load_config()
  local config_file = awful.util.get_configuration_dir() .. "layoutstatus.conf"
  local f = io.open(config_file, "r")
  if f then
    for line in f:lines() do
      local key, value = line:match("^(%S+)%s*=%s*(%S+)$")
      if key == "output_file" then
        output_file = value
      end
    end
    f:close()
  end
end

-- Load configuration
load_config()

local module = {
  icons = icons,
  get_layout_output = get_layout_output,
  notify = write_layout_info_to_fifo,
  init = init_mkfifo
}

return module

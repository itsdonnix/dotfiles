local awful = require("awful")
local naughty = require("naughty")

-- Default output file path
local output_file = "/tmp/awesomewm-layout-status"

-- Map layout to icon and abbreviation
local icons = {
  ["tile"]                = "󰖯 TILE",
  ["tileleft"]            = "󰕮 TLEF",
  ["tiletop"]             = "󰕮 TTOP",
  ["tilebottom"]          = "󰕮 TBOT",
  ["fair"]                = "󰕰 FAIR",
  ["fairh"]               = "󰘧 FHOR",
  ["fairv"]               = "󰘧 FVER",
  ["spiral"]              = "󰘚 SPIR",
  ["dwindle"]             = "󰧑 DWIN",
  ["max"]                 = "󰊓 MAX",
  ["fullscreen"]          = "󰖳 FULL",
  ["floating"]            = "󰈼 FLOT",
  ["magnifier"]           = "󰒱 MAGN",
  ["cornernw"]            = "󱉶 CNW",
  ["cornerne"]            = "󱉶 CNE",
  ["cornersw"]            = "󱉶 CSW",
  ["cornerse"]            = "󱉶 CSE",
}

local function get_icon_label(name)
  if icons[name] then
    return icons[name]
  else
    -- fallback icon + first 4 uppercase chars of name
    return "󰘥 " .. (name:sub(1, 4):upper())
  end
end

-- local function init_mkfifo()
--   awful.spawn.once("[ -p " .. output_file .. " ] || mkfifo --mode=666 " .. output_file)
-- end

-- init_mkfifo()

local prev_layout = ""

local function write_layout_info_to_fifo(layout)
  if prev_layout == layout.name then
    return
  end

  name_with_icon = get_icon_label(layout.name)
  naughty.notify({
                    -- preset = naughty.config.presets.critical,
                    title = "Layout Change",
                    text = name_with_icon,
                    timeout = 1.5
                })

  prev_layout = layout.name

  -- local name = awful.layout.getname(layout)

  -- local output = get_icon_label(layout.name)
  -- awful.spawn.with_shell("echo '" .. output .. "' > " .. output_file)
  
  -- awful.spawn.with_shell("echo '" .. output .. "' >&3")
end

local module = {
  notify = write_layout_info_to_fifo,
  --init = init_mkfifo
}

return module

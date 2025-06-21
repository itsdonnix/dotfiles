local theme_assets                              = require("beautiful.theme_assets")
local xresources                                = require("beautiful.xresources")
local dpi                                       = xresources.apply_dpi

local gfs                                       = require("gears.filesystem")
local themes_path                               = gfs.get_themes_dir()

local theme                                     = {}

-- Color palletes
local color_background                          = "#282A36"
local color_foreground                          = "#F8F8F2"
local color_black                               = "#21222C"
local color_red                                 = "#FF5555"
local color_green                               = "#50FA7B"
local color_yellow                              = "#F1FA8C"
local color_blue                                = "#BD93F9"
local color_magenta                             = "#FF79C6"
local color_cyan                                = "#8BE9FD"
local color_light_gray                          = "#44475A"
local color_darker_blue                         = "#6272A4"
local color_light_red                           = "#FF5555"
local color_light_green                         = "#50FA7B"
local color_light_yellow                        = "#F1FA8C"
local color_light_blue                          = "#BD93F9"
local color_light_magenta                       = "#FF79C6"
local color_light_cyan                          = "#8BE9FD"
local color_white                               = "#F8F8F2"

-- Background and Foreground
theme.bg_normal                                 = color_background
theme.fg_normal                                 = color_foreground
theme.bg_focus                                  = color_light_gray
theme.fg_focus                                  = color_foreground
theme.bg_urgent                                 = color_red
theme.fg_urgent                                 = color_foreground
theme.bg_minimize                               = color_black
theme.fg_minimize                               = color_foreground
theme.bg_systray                                = theme.bg_normal

-- Borders
theme.border_width                              = dpi(1)
theme.border_normal                             = color_light_gray
theme.border_focus                              = color_blue
theme.border_marked                             = color_red

-- Font
theme.font                                      = "CaskaydiaCove Nerd Font 12"

-- Taglist settings
theme.taglist_fg_focus                          = theme.fg_focus
theme.taglist_bg_focus                          = theme.bg_focus
theme.taglist_fg_urgent                         = theme.fg_urgent
theme.taglist_bg_urgent                         = theme.bg_urgent
theme.taglist_fg_normal                         = theme.fg_normal
theme.taglist_bg_normal                         = theme.bg_normal

-- Tasklist settings
theme.tasklist_disable_icon                     = true
theme.tasklist_fg_focus                         = theme.fg_focus
theme.tasklist_bg_focus                         = theme.bg_normal
theme.tasklist_fg_urgent                        = theme.fg_urgent
theme.tasklist_bg_urgent                        = theme.bg_urgent
theme.tasklist_fg_normal                        = theme.fg_normal
theme.tasklist_bg_normal                        = theme.bg_normal

-- Menu settings
theme.menu_submenu_icon                         = themes_path .. "default/submenu.png"
theme.menu_height                               = dpi(22.5)
theme.menu_width                                = dpi(200)
theme.menu_bg_normal                            = theme.bg_normal
theme.menu_fg_normal                            = theme.fg_normal
theme.menu_bg_focus                             = theme.bg_focus
theme.menu_fg_focus                             = theme.fg_focus
theme.menu_border_color                         = color_blue
theme.menu_border_width                         = 1

-- Titlebar settings
theme.titlebar_bg_normal                        = theme.bg_normal
theme.titlebar_bg_focus                         = theme.bg_normal
theme.titlebar_icon_spacing                     = 5

theme.titlebar_close_button_normal              = themes_path .. "default/titlebar/close_normal.png"
theme.titlebar_close_button_focus               = themes_path .. "default/titlebar/close_focus.png"

theme.titlebar_minimize_button_normal           = themes_path .. "default/titlebar/minimize_normal.png"
theme.titlebar_minimize_button_focus            = themes_path .. "default/titlebar/minimize_focus.png"

theme.titlebar_ontop_button_normal_inactive     = themes_path .. "default/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive      = themes_path .. "default/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active       = themes_path .. "default/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active        = themes_path .. "default/titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive    = themes_path .. "default/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive     = themes_path .. "default/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active      = themes_path .. "default/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active       = themes_path .. "default/titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive  = themes_path .. "default/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive   = themes_path .. "default/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active    = themes_path .. "default/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active     = themes_path .. "default/titlebar/floating_focus_active.png"

theme.titlebar_maximized_button_normal_inactive = themes_path .. "default/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive  = themes_path .. "default/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active   = themes_path .. "default/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active    = themes_path .. "default/titlebar/maximized_focus_active.png"

-- Wallpaper (set to your own wallpaper if desired)
-- theme.wallpaper = themes_path.."default/background.png"

-- Layout icons
theme.layout_fairh                              = themes_path .. "default/layouts/fairhw.png"
theme.layout_fairv                              = themes_path .. "default/layouts/fairvw.png"
theme.layout_floating                           = themes_path .. "default/layouts/floatingw.png"
theme.layout_magnifier                          = themes_path .. "default/layouts/magnifierw.png"
theme.layout_max                                = themes_path .. "default/layouts/maxw.png"
theme.layout_fullscreen                         = themes_path .. "default/layouts/fullscreenw.png"
theme.layout_tilebottom                         = themes_path .. "default/layouts/tilebottomw.png"
theme.layout_tileleft                           = themes_path .. "default/layouts/tileleftw.png"
theme.layout_tile                               = themes_path .. "default/layouts/tilew.png"
theme.layout_tiletop                            = themes_path .. "default/layouts/tiletopw.png"
theme.layout_spiral                             = themes_path .. "default/layouts/spiralw.png"
theme.layout_dwindle                            = themes_path .. "default/layouts/dwindlew.png"
theme.layout_cornernw                           = themes_path .. "default/layouts/cornernww.png"
theme.layout_cornerne                           = themes_path .. "default/layouts/cornernew.png"
theme.layout_cornersw                           = themes_path .. "default/layouts/cornersww.png"
theme.layout_cornerse                           = themes_path .. "default/layouts/cornersew.png"

-- Awesome icon
theme.awesome_icon                              = theme_assets.awesome_icon(
    theme.menu_height, theme.bg_focus, theme.fg_focus
)

-- Icon theme for application icons
theme.icon_theme                                = nil

-- Usable gap setting for window spacing
theme.useless_gap                               = dpi(3)

return theme

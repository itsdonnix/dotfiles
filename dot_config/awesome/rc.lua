-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- Load Debian menu entries
local debian = require("debian.menu")
local has_fdo, freedesktop = pcall(require, "freedesktop")

-- Plugins
local sharedtags = require("plugins.sharedtags")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify(
        {
            preset = naughty.config.presets.critical,
            title = "Oops, there were errors during startup!",
            text = awesome.startup_errors
        }
    )
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal(
        "debug::error",
        function(err)
            -- Make sure we don't go into an endless error loop
            if in_error then
                return
            end
            in_error = true

            naughty.notify(
                {
                    preset = naughty.config.presets.critical,
                    title = "Oops, an error happened!",
                    text = tostring(err)
                }
            )
            in_error = false
        end
    )
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
-- beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
beautiful.init(gears.filesystem.get_configuration_dir() .. "themes/default/theme.lua")

-- Load config
local config = require("config")

-- This is used later as the default terminal and editor to run.
local terminal = "x-terminal-emulator"
local editor = os.getenv("EDITOR") or "editor"
local editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
local modkey = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.max,
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    -- awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.corner.nw
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}

local tags =
    sharedtags(
        {
            { name = "1st", layout = awful.layout.layouts[1], screen = 1 },
            { name = "2nd", layout = awful.layout.layouts[1], screen = 1 },
            { name = "3rd", layout = awful.layout.layouts[1], screen = 1 }
            --{ name = "4th", layout = awful.layout.layouts[1], screen = 2 },
            --{ name = "5th", layout = awful.layout.layouts[1], screen = 2 },
            --{ name = "6th", layout = awful.layout.layouts[1], screen = 2 }
            --{ layout = awful.layout.layouts[1] },
            --{ screen = 2, layout = awful.layout.layouts[1] }
        }
    )
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
local myawesomemenu = {
    { "hotkeys", function()
        hotkeys_popup.show_help(nil, awful.screen.focused())
    end
    },
    { "manual",      terminal .. " -e man awesome" },
    { "edit config", editor_cmd .. " " .. awesome.conffile },
    { "restart",     awesome.restart },
    { "quit",        function() awesome.quit() end }
}

local menu_awesome = { "awesome", myawesomemenu, beautiful.awesome_icon }
local menu_terminal = { "open terminal", terminal }
local mymainmenu = {}

if has_fdo then
    mymainmenu =
        freedesktop.menu.build(
            {
                before = { menu_awesome },
                after = { menu_terminal }
            }
        )
else
    mymainmenu =
        awful.menu(
            {
                items = {
                    menu_awesome,
                    { "Debian", debian.menu.Debian_menu.Debian },
                    menu_terminal
                }
            }
        )
end

local mylauncher =
    awful.widget.launcher(
        {
            image = beautiful.awesome_icon,
            menu = mymainmenu
        }
    )

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

if config.wibar.enabled then
    -- Keyboard map indicator and switcher
    mykeyboardlayout = awful.widget.keyboardlayout()
end

-- {{{ Wibar
if config.wibar.enabled then
    -- Create a textclock widget
    mytextclock = wibox.widget.textclock(" %a %b %d,%I:%M %p ")

    -- Create a wibox for each screen and add it
    taglist_buttons =
        gears.table.join(
            awful.button(
                {},
                1,
                function(t)
                    t:view_only()
                end
            ),
            awful.button(
                { modkey },
                1,
                function(t)
                    if client.focus then
                        client.focus:move_to_tag(t)
                    end
                end
            ),
            awful.button({}, 3, awful.tag.viewtoggle),
            awful.button(
                { modkey },
                3,
                function(t)
                    if client.focus then
                        client.focus:toggle_tag(t)
                    end
                end
            ),
            awful.button(
                {},
                4,
                function(t)
                    awful.tag.viewnext(t.screen)
                end
            ),
            awful.button(
                {},
                5,
                function(t)
                    awful.tag.viewprev(t.screen)
                end
            )
        )

    tasklist_buttons =
        gears.table.join(
        -- awful.button({ }, 1, function (c)
        -- if c == client.focus then
        -- c.minimized = true
        -- else
        -- c:emit_signal(
        -- "request::activate",
        -- "tasklist",
        -- {raise = true}
        -- )
        -- end
        -- end),
            awful.button(
                {},
                3,
                function()
                    awful.menu.client_list({
                        theme = { width = 250 },
                    })
                end
            ),
            awful.button(
                {},
                4,
                function()
                    awful.client.focus.byidx(1)
                end
            ),
            awful.button(
                {},
                5,
                function()
                    awful.client.focus.byidx(-1)
                end
            )
        )
end

local function set_wallpaper(s)
    -- If called without a screen, apply it to all screens
    if not s then
        for _, sc in ipairs(screen.count and screen or screen) do
            set_wallpaper(sc)
        end
        return
    end

    local fehbg = os.getenv("HOME") .. "/.fehbg"
    if gears.filesystem.file_readable(fehbg) then
        awful.spawn.with_shell('sh "' .. fehbg .. '"')
    else
        naughty.notify({
            preset = naughty.config.presets.critical,
            title  = "Error loading wallpaper",
            text   = "No ~/.fehbg file found or it's not readable."
        })
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(
    function(s)
        -- Wallpaper
        set_wallpaper(s)

        if config.wibar.enabled then
            -- Each screen has its own tag table.
            awful.tag({ "1st", "2nd", "3rd" }, s, awful.layout.layouts[1])

            -- Create a promptbox for each screen
            s.mypromptbox = awful.widget.prompt()
        end

        if config.wibar.show_current_layout_indicator then
            -- Create an imagebox widget which will contain an icon indicating which layout we're using.
            -- We need one layoutbox per screen.
            s.mylayoutbox = awful.widget.layoutbox(s)
            s.mylayoutbox:buttons(gears.table.join(
                awful.button({}, 1, function() awful.layout.inc(1) end),
                awful.button({}, 3, function() awful.layout.inc(-1) end),
                awful.button({}, 4, function() awful.layout.inc(1) end),
                awful.button({}, 5, function() awful.layout.inc(-1) end)))
        end

        if config.wibar.enabled then
            -- Create a taglist widget
            s.mytaglist =
                awful.widget.taglist {
                    screen = s,
                    filter = awful.widget.taglist.filter.all,
                    buttons = taglist_buttons
                }
            -- Create a tasklist widget
            s.mytasklist =
                awful.widget.tasklist {
                    screen = s,
                    -- filter  = awful.widget.tasklist.filter.currenttags,
                    filter = function(c)
                        return c == client.focus
                    end,
                    buttons = tasklist_buttons,
                    widget_template = {
                        {
                            {
                                {
                                    id = "icon_role",
                                    widget = wibox.widget.imagebox
                                },
                                margins = 3,
                                widget = wibox.container.margin
                            },
                            {
                                id = "text_role",
                                widget = wibox.widget.textbox
                            },
                            layout = wibox.layout.fixed.horizontal
                        },
                        left = 10,
                        right = 10,
                        widget = wibox.container.margin
                    },
                    id = "background_role",
                    widget = wibox.container.background
                }
            -- Create the wibox
            s.mywibox = awful.wibar({ position = "top", screen = s })
            -- Add widgets to the wibox
            s.mywibox:setup {
                layout = wibox.layout.align.horizontal,
                {
                    -- Left widgets
                    layout = wibox.layout.fixed.horizontal,
                    --mylauncher,
                    s.mytaglist,
                    s.mypromptbox
                },
                s.mytasklist, -- Middle widget:
                {
                    -- Right widgets
                    layout = wibox.layout.fixed.horizontal,
                    mykeyboardlayout,
                    wibox.widget.systray(),
                    mytextclock
                    --s.mylayoutbox,
                }
            }
        else
            awful.spawn(os.getenv("HOME") .. "/.config/polybar/launch.sh")
        end
    end
)
-- }}}

-- {{{ Mouse bindings
root.buttons(
    gears.table.join(
        awful.button(
            {},
            3,
            function()
                mymainmenu:toggle()
            end
        )
    -- awful.button({ }, 4, awful.tag.viewnext),
    -- awful.button({ }, 5, awful.tag.viewprev)
    )
)
-- }}}

-- {{{ Key bindings
local globalkeys =
    gears.table.join(
        awful.key({ modkey }, "s", hotkeys_popup.show_help, { description = "show help", group = "awesome" }),
        awful.key({ modkey, "Shift" }, "Left", awful.tag.viewprev, { description = "view previous", group = "tag" }),
        awful.key({ modkey, "Shift" }, "Right", awful.tag.viewnext, { description = "view next", group = "tag" }),
        awful.key({ modkey }, "Escape", awful.tag.history.restore, { description = "go back", group = "tag" }),
        awful.key(
            { modkey },
            "j",
            function()
                awful.client.focus.byidx(1)
            end,
            { description = "focus next by index", group = "client" }
        ),
        awful.key(
            { modkey },
            "k",
            function()
                awful.client.focus.byidx(-1)
            end,
            { description = "focus previous by index", group = "client" }
        ),
        --awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
        --{ description = "show main menu", group = "awesome" }),

        -- Layout manipulation
        awful.key(
            { modkey, "Shift" },
            ".",
            function()
                awful.client.swap.byidx(1)
            end,
            { description = "swap with next client by index", group = "client" }
        ),
        awful.key(
            { modkey, "Shift" },
            ",",
            function()
                awful.client.swap.byidx(-1)
            end,
            { description = "swap with previous client by index", group = "client" }
        ),
        awful.key(
            { modkey },
            ".",
            function()
                awful.screen.focus_relative(1)
            end,
            { description = "focus the next screen", group = "screen" }
        ),
        awful.key(
            { modkey },
            ",",
            function()
                awful.screen.focus_relative(-1)
            end,
            { description = "focus the previous screen", group = "screen" }
        ),
        awful.key({ modkey }, "u", awful.client.urgent.jumpto,
            { description = "jump to urgent client", group = "client" }),
        awful.key(
            { modkey },
            "Tab",
            function()
                awful.client.focus.history.previous()
                if client.focus then
                    client.focus:raise()
                end
            end,
            { description = "go back", group = "client" }
        ),
        -- Standard program
        awful.key(
            { modkey },
            "Return",
            function()
                awful.spawn(terminal)
            end,
            { description = "open a terminal", group = "launcher" }
        ),
        awful.key({ modkey, "Control" }, "r", awesome.restart, { description = "reload awesome", group = "awesome" }),
        awful.key({ modkey, "Shift" }, "q", awesome.quit, { description = "quit awesome", group = "awesome" }),
        awful.key(
            {},
            "Print",
            function()
                awful.util.spawn("flameshot gui", false)
            end,
            { description = "screenshot", group = "utilities" }
        ),
        awful.key(
            { modkey },
            "l",
            function()
                awful.tag.incmwfact(0.05)
            end,
            { description = "increase master width factor", group = "layout" }
        ),
        awful.key(
            { modkey },
            "h",
            function()
                awful.tag.incmwfact(-0.05)
            end,
            { description = "decrease master width factor", group = "layout" }
        ),
        awful.key(
            { modkey, "Shift" },
            "h",
            function()
                awful.tag.incnmaster(1, nil, true)
            end,
            { description = "increase the number of master clients", group = "layout" }
        ),
        awful.key(
            { modkey, "Shift" },
            "l",
            function()
                awful.tag.incnmaster(-1, nil, true)
            end,
            { description = "decrease the number of master clients", group = "layout" }
        ),
        awful.key(
            { modkey, "Control" },
            "h",
            function()
                awful.tag.incncol(1, nil, true)
            end,
            { description = "increase the number of columns", group = "layout" }
        ),
        awful.key(
            { modkey, "Control" },
            "l",
            function()
                awful.tag.incncol(-1, nil, true)
            end,
            { description = "decrease the number of columns", group = "layout" }
        ),
        awful.key(
            { modkey },
            "space",
            function()
                awful.layout.inc(1)
            end,
            { description = "select next", group = "layout" }
        ),
        awful.key(
            { modkey, "Shift" },
            "space",
            function()
                awful.layout.inc(-1)
            end,
            { description = "select previous", group = "layout" }
        ),
        awful.key(
            { modkey, "Control" },
            "n",
            function()
                local c = awful.client.restore()
                -- Focus restored client
                if c then
                    c:emit_signal("request::activate", "key.unminimize", { raise = true })
                end
            end,
            { description = "restore minimized", group = "client" }
        ),
        -- Launchers
        awful.key(
            { modkey },
            "r",
            function()
                awful.spawn("rofi -show run")
            end,
            { description = "run command", group = "launcher" }
        ),
        --awful.key({ modkey, "Shift" },    "r", function () awful.spawn("xfce4-appfinder") end,
        --{ description = "xfce4 application finder", group = "launcher" }),

        awful.key(
            { modkey },
            "a",
            function()
                awful.spawn("rofi -show drun")
            end,
            { description = "run application", group = "launcher" }
        ),
        awful.key(
            { modkey },
            "p",
            function()
                awful.spawn("rofi -show run")
            end,
            { description = "run command", group = "launcher" }
        ),
        awful.key(
            { modkey },
            "w",
            function()
                awful.spawn("rofi -show window")
            end,
            { description = "window list", group = "launcher" }
        )
    )

local clientkeys =
    gears.table.join(
        awful.key(
            { modkey },
            "f",
            function(c)
                c.fullscreen = not c.fullscreen
                c:raise()
            end,
            { description = "toggle fullscreen", group = "client" }
        ),
        awful.key(
            { modkey, "Shift" },
            "c",
            function(c)
                c:kill()
            end,
            { description = "close", group = "client" }
        ),
        awful.key(
            { modkey, "Control" },
            "space",
            awful.client.floating.toggle,
            { description = "toggle floating", group = "client" }
        ),
        awful.key(
            { modkey, "Control" },
            "Return",
            function(c)
                c:swap(awful.client.getmaster())
            end,
            { description = "move to master", group = "client" }
        ),
        awful.key(
            { modkey },
            "o",
            function(c)
                c:move_to_screen()
            end,
            { description = "move to screen", group = "client" }
        ),
        awful.key(
            { modkey },
            "t",
            function(c)
                c.ontop = not c.ontop
            end,
            { description = "toggle keep on top", group = "client" }
        ),
        awful.key(
            { modkey },
            "n",
            function(c)
                -- The client currently has the input focus, so it cannot be
                -- minimized, since minimized clients can't have the focus.
                c.minimized = true
            end,
            { description = "minimize", group = "client" }
        ),
        awful.key(
            { modkey },
            "m",
            function(c)
                c.maximized = not c.maximized
                c:raise()
            end,
            { description = "(un)maximize", group = "client" }
        ),
        awful.key(
            { modkey, "Control" },
            "m",
            function(c)
                c.maximized_vertical = not c.maximized_vertical
                c:raise()
            end,
            { description = "(un)maximize vertically", group = "client" }
        ),
        awful.key(
            { modkey, "Shift" },
            "m",
            function(c)
                c.maximized_horizontal = not c.maximized_horizontal
                c:raise()
            end,
            { description = "(un)maximize horizontally", group = "client" }
        ),
        awful.key(
            { modkey },
            "b",
            function()
                local myscreen = awful.screen.focused()
                if config.wibar.enabled then
                    myscreen.mywibox.visible = not myscreen.mywibox.visible
                else
                    awful.spawn("polybar-msg cmd toggle")
                end
            end,
            { description = "toggle statusbar", group = "custom" }
        )
    )

if config.client.titlebar.enabled then
    clientkeys = gears.table.join(
        clientkeys,
        awful.key(
            { modkey, "Control" },
            "t",
            function(c)
                awful.titlebar.toggle(c)
            end,
            { description = "toggle title bar", group = "client" }
        )
    )
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys =
        gears.table.join(
            globalkeys,
            -- View tag only.
            awful.key(
                { modkey },
                "#" .. i + 9,
                function()
                    local screen = awful.screen.focused()
                    local tag = screen.tags[i]
                    if tag then
                        --tag:view_only()
                        sharedtags.viewonly(tag, screen)
                    end
                end,
                { description = "view tag #" .. i, group = "tag" }
            ),
            -- Toggle tag display.
            awful.key(
                { modkey, "Control" },
                "#" .. i + 9,
                function()
                    local screen = awful.screen.focused()
                    local tag = screen.tags[i]
                    if tag then
                        --awful.tag.viewtoggle(tag)
                        sharedtags.viewtoggle(tag, screen)
                    end
                end,
                { description = "toggle tag #" .. i, group = "tag" }
            ),
            -- Move client to tag.
            awful.key(
                { modkey, "Shift" },
                "#" .. i + 9,
                function()
                    if client.focus and client.focus.screen and client.focus.screen.tags[i] then
                        local tag = client.focus.screen.tags[i]
                        client.focus:move_to_tag(tag)
                    end
                end,
                { description = "move focused client to tag #" .. i, group = "tag" }
            ),
            -- Toggle tag on focused client.
            awful.key(
                { modkey, "Control", "Shift" },
                "#" .. i + 9,
                function()
                    if client.focus and client.focus.screen and client.focus.screen.tags[i] then
                        local tag = client.focus.screen.tags[i]
                        client.focus:move_to_tag(tag)
                    end
                end,
                { description = "toggle focused client on tag #" .. i, group = "tag" }
            )
        )
end

local clientbuttons = gears.table.join(
    awful.button(
        {},
        1,
        function(c)
            c:emit_signal("request::activate", "mouse_click", { raise = true })
        end
    ),
    awful.button(
        { modkey },
        1,
        function(c)
            c:emit_signal("request::activate", "mouse_click", { raise = true })
            awful.mouse.client.move(c)
        end
    ),
    awful.button(
        { modkey },
        3,
        function(c)
            c:emit_signal("request::activate", "mouse_click", { raise = true })
            awful.mouse.client.resize(c)
        end
    )
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    {
        rule = {},
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap + awful.placement.no_offscreen
        }
    },

    -- Floating clients.
    {
        rule_any   = {
            instance = {
                "DTA",   -- Firefox addon DownThemAll.
                "copyq", -- Includes session name in class.
                "pinentry"
            },
            class = {
                "Arandr",
                "Blueman-manager",
                "Gpick",
                "Kruler",
                "MessageWin",  -- kalarm.
                "Sxiv",
                "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
                "Wpa_gui",
                "veromix",
                "xtightvncviewer",
                "nm-connection-editor",
                "Gcr-prompter"
            },
            -- Note that the name property shown in xprop might be set slightly after creation of the client
            -- and the name shown there might not match defined rules here.
            name = {
                "Event Tester" -- xev.
            },
            role = {
                "AlarmWindow",   -- Thunderbird's calendar.
                "ConfigManager", -- Thunderbird's about:config.
                "pop-up"         -- e.g. Google Chrome's (detached) Developer Tools.
            },
            type = { "dialog" }
        },
        properties = {
            floating = true,
        },
        callback   = function(c)
            awful.placement.centered(c, {
                offset = { x = 0, y = -50 }
            })
        end
    },

    -- Add titlebars to normal clients and dialogs
    {
        rule_any = {
            type = { "normal", "dialog" }
        },
        properties = {
            titlebars_enabled = config.client.titlebar.enabled,
        }
    },

    -- Make some dialogs to be not floating
    {
        rule_any = {
            class = { "Blueman-manager" }
        },
        properties = {
            floating = false,
            maximized = false
        }
    },

    -- Polybar
    {
        rule = { class = "Polybar" },
        properties = {
            floating = true,
            above = true,
            sticky = true,
            border_width = 0,
            screen = function() return awful.screen.focused() end,
            focusable = false,
            type = "dock"
        }
    },

    -- Rule for Chromium-based app windows (e.g. web apps launched with --app=...)
    -- These often use instance names starting with "crx_" and tend to open as floating or maximized.
    -- This rule ensures they open in tiling mode by default.
    {
        rule = { instance = "crx_" },
        properties = {
            floating = false,
            maximized = false,
            maximized_vertical = false,
            maximized_horizontal = false
        }
    },

    -- Make Brave --app windows (like ChatGPT) tile and hide titlebar
    {
        rule_any = {
            class = { "Brave-browser" },
            -- Match window names of specific apps opened with --app= (add more as needed)
            name  = { "ChatGPT" },
            role  = { "pop-up" }
        },
        properties = {
            floating = false
        },
        callback = function(c)
            c.floating = false     -- Disable floating
            awful.titlebar.hide(c) -- Hide titlebar for cleaner look
        end
    }

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal(
    "manage",
    function(c)
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- if not awesome.startup then awful.client.setslave(c) end

        if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
            -- Prevent clients from being unreachable after screen count changes.
            awful.placement.no_offscreen(c)
        end

        if config.client.titlebar.enabled then
            -- Hide the titlebar
            awful.titlebar.hide(c)
        end
    end
)

if config.client.titlebar.enabled then
    -- Add a titlebar if titlebars_enabled is set to true in the rules.
    client.connect_signal(
        "request::titlebars",
        function(c)
            -- buttons for the titlebar
            local buttons =
                gears.table.join(
                    awful.button(
                        {},
                        1,
                        function()
                            c:emit_signal("request::activate", "titlebar", { raise = true })
                            awful.mouse.client.move(c)
                        end
                    ),
                    awful.button(
                        {},
                        3,
                        function()
                            c:emit_signal("request::activate", "titlebar", { raise = true })
                            awful.mouse.client.resize(c)
                        end
                    )
                )

            awful.titlebar(c):setup {
                {
                    -- Left
                    {
                        {
                            widget = awful.titlebar.widget.iconwidget(c)
                        },
                        widget = wibox.container.margin,
                        margins = beautiful.titlebar_icon_spacing
                    },
                    buttons = buttons,
                    layout = wibox.layout.fixed.horizontal
                },
                {
                    -- Middle
                    {
                        -- Title
                        align = "center",
                        widget = awful.titlebar.widget.titlewidget(c)
                    },
                    buttons = buttons,
                    layout = wibox.layout.flex.horizontal
                },
                {
                    -- Right
                    {
                        {
                            widget = awful.titlebar.widget.floatingbutton(c)
                        },
                        widget = wibox.container.margin,
                        margins = beautiful.titlebar_icon_spacing
                    },
                    {
                        {
                            widget = awful.titlebar.widget.maximizedbutton(c)
                        },
                        widget = wibox.container.margin,
                        margins = beautiful.titlebar_icon_spacing
                    },
                    {
                        {
                            widget = awful.titlebar.widget.stickybutton(c)
                        },
                        widget = wibox.container.margin,
                        margins = beautiful.titlebar_icon_spacing
                    },
                    {
                        {
                            widget = awful.titlebar.widget.ontopbutton(c)
                        },
                        widget = wibox.container.margin,
                        margins = beautiful.titlebar_icon_spacing
                    },
                    {
                        {
                            widget = awful.titlebar.widget.closebutton(c)
                        },
                        widget = wibox.container.margin,
                        margins = beautiful.titlebar_icon_spacing
                    },
                    layout = wibox.layout.fixed.horizontal()
                },
                layout = wibox.layout.align.horizontal
            }
        end
    )
    --
end

--[[
-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)
]]

-- Set the focus border color temporarily
local function change_border_color(c)
    if not (c and c.valid) then
        return
    end
    c.border_color = beautiful.border_focus

    gears.timer {
        timeout     = 2,
        autostart   = true,
        single_shot = true,
        callback    = function()
            if c and c.valid then
                c.border_color = beautiful.border_normal
            end
        end,
    }
end

-- client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal(
    "focus",
    function(c)
        change_border_color(c)
    end
)

client.connect_signal(
    "unfocus",
    function(c)
        c.border_color = beautiful.border_normal
    end
)
-- }}}
--

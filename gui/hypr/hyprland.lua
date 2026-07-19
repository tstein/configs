--------------------
-- defs and utils --
--------------------
oregon_blue = "#306ac0bb";
-- send a hyprland-native notification
function notify(msg)
  hl.notification.create({ text = msg, timeout = 2000, color = oregon_blue})
end
-- callback version for binds
function notify_cb(msg)
  return function()
    hl.notification.create({ text = msg, timeout = 2000, color = oregon_blue})
  end
end

-- turn off the meme stuff
hl.config({
  misc = {
    force_default_wallpaper = 0,
    disable_hyprland_logo   = false,
    disable_splash_rendering = true, -- also disables the quotes
  },
})


--------------
-- env vars --
--------------
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("GTK_THEME", "Adwaita:dark")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct") -- don't forget to actually *run* qt6ct


-----------------------------
-- decorations and effects --
-----------------------------
hl.config({
  general = {
    gaps_in  = 2,
    gaps_out = 4,
    border_size = 2,
    col = {
      active_border = {
        colors = { "rgba(ff7900ee)", "rgba(306ac0ee)" },
        angle = 45
      },
      inactive_border = "rgba(595959aa)",
    },
  },
  decoration = {
    rounding = 5,
  },
})


-------------
-- layouts --
-------------
hl.config({
  dwindle = {
    preserve_split = true,
    -- always split right / down instead of left / up, instead of choosing one
    -- or the other based on mouse position
    force_split = 2,
  },
  scrolling = {
    fullscreen_on_one_column = true,
    column_width = .99,
  },
})

function cycle_layouts()
  local layouts = { "dwindle", "scrolling", }
  local workspace = hl.get_active_workspace()
  if hl.get_active_special_workspace() then
    workspace = hl.get_active_special_workspace()
  end
  if not workspace then
    return
  end

  local next_layout = layouts[0]
  for i = 1, #layouts do
    if layouts[i] == workspace.tiled_layout then
      local next_layout_idx = (i % #layouts) + 1
      next_layout = layouts[next_layout_idx]
      break
    end
  end

  if workspace.special then
    hl.workspace_rule({ workspace = tostring(workspace.name), layout = next_layout })
  else
    hl.workspace_rule({ workspace = tostring(workspace.id), layout = next_layout })
  end
  notify("layout: " .. next_layout)
end


---------------------
-- workspace rules --
---------------------
-- workspace 3 is for terminals
hl.workspace_rule({ workspace = "3", layout = "scrolling" })

-- no gaps when there's a single tiled window ("smart gaps")
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0 })
hl.window_rule({ match = { float = false, workspace = "w[tv1]" }, rounding = 0 })
hl.window_rule({ match = { float = false, workspace = "f[1]" }, rounding = 0 })


------------------
-- window rules --
------------------
hl.window_rule({ match = { class = ".*" }, float = true, persistent_size = true })
-- new firefox floats are tiny without this
hl.window_rule({ match = { class = "firefox" }, size = { "(monitor_w * 0.6)", "(monitor_h * 0.6)" }})

hl.window_rule({
  name  = "suppress-maximize-events",
  match = { class = ".*" },
  suppress_event = "maximize",
})

hl.window_rule({
  name  = "fix-xwayland-drags",
  match = {
    class      = "^$",
    title      = "^$",
    xwayland   = true,
    float      = true,
    fullscreen = false,
    pin        = false,
  },
  no_focus = true,
})


----------------
-- animations --
----------------
hl.animation({ leaf = "global", enabled = true, speed = 1.5, bezier = "default" })


-----------
-- input --
-----------
hl.config({
  input = {
    kb_layout  = "us,ara",
    kb_options = "grp:alt_space_toggle,compose:caps",
    numlock_by_default = true,

    -- need both to disable focus-follows-mouse entirely.
    follow_mouse = 0,
    float_switch_override_focus = 0,

    touchpad = {
      natural_scroll = true,
    },
  },
})

hl.gesture({
  fingers = 3,
  direction = "horizontal",
  action = "workspace"
})


--------------
-- bindings --
--------------
-- shortcuts
hl.bind("SUPER + RETURN", hl.dsp.exec_cmd("ghostty"))
hl.bind("SUPER + SHIFT + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region"))

-- runners
hl.bind("SUPER + ALT + C", hl.dsp.exec_cmd("strawberry"))
hl.bind("SUPER + ALT + N", hl.dsp.exec_cmd("nemo"))
hl.bind("SUPER + ALT + Q", hl.dsp.exec_cmd("qalculate-gtk"))
hl.bind("SUPER + D", hl.dsp.exec_cmd("PATH=~/.local/bin:$PATH bemenu-run"))
hl.bind("SUPER + SHIFT + D", hl.dsp.exec_cmd("hyprlauncher"))

-- window management
hl.bind("SUPER + SHIFT + C", hl.dsp.window.close())
hl.bind("SUPER + TAB", cycle_layouts)
hl.bind("SUPER + F", hl.dsp.window.fullscreen())
hl.bind("SUPER + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + P", hl.dsp.window.pseudo())
-- switch between vertical and horizontal splitting (only valid for dwindle)
hl.bind("SUPER + SPACE", hl.dsp.layout("togglesplit"))

-- move focus by monitor
hl.bind("SUPER + W", hl.dsp.focus({ monitor = "-1" }))
hl.bind("SUPER + E", hl.dsp.focus({ monitor = "+1" }))
-- move window by monitor
hl.bind("SUPER + SHIFT + W", hl.dsp.window.move({ monitor = "-1" }))
hl.bind("SUPER + SHIFT + E", hl.dsp.window.move({ monitor = "+1" }))
-- move workspace by monitor
hl.bind("SUPER + ALT + SHIFT + W", hl.dsp.workspace.move({ monitor = "-1" }))
hl.bind("SUPER + ALT + SHIFT + E", hl.dsp.workspace.move({ monitor = "+1" }))

-- move focus by direction
hl.bind("SUPER + left",  hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + up",    hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + down",  hl.dsp.focus({ direction = "down" }))
-- move window by direction
hl.bind("SUPER + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind("SUPER + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind("SUPER + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind("SUPER + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

-- focus/move window by workspace number
for i = 1, 10 do
  local key = i % 10
  hl.bind("SUPER + " .. key,         hl.dsp.focus({ workspace = i }))
  hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- scroll through workspaces with mouse wheel
-- indices have the opposite of the effect you expect
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + mouse_down",   hl.dsp.focus({ workspace = "e-1" }))

-- drag/resize by mouse
--               left click
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(),   { mouse = true })
--               right click
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- media keys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 2%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
hl.bind("XF86AudioStop",  hl.dsp.exec_cmd("playerctl stop"),       { locked = true })
hl.bind("SHIFT + XF86AudioNext",  hl.dsp.exec_cmd("playerctl -p strawberry next"),       { locked = true })
hl.bind("SHIFT + XF86AudioPlay",  hl.dsp.exec_cmd("playerctl -p strawberry play-pause"), { locked = true })
hl.bind("SHIFT + XF86AudioPrev",  hl.dsp.exec_cmd("playerctl -p strawberry previous"),   { locked = true })
hl.bind("SHIFT + XF86AudioStop",  hl.dsp.exec_cmd("playerctl -p strawberry stop"),       { locked = true })

hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 4%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 4%-"), { locked = true, repeating = true })


---------------
-- autostart --
---------------
autostart_cmds = {
  -- complete the DE
  "hypridle",
  "hyprpaper",
  "swaync || mako",
  "waybar",
  -- tray programs
  "blueman-applet",
  "nm-applet",
  "keepassxc",
  "strawberry",
}

-- to add more:
function autostart(cmd)
  table.insert(autostart_cmds, cmd)
end

hl.on("hyprland.start", function()
  for _, cmd in pairs(autostart_cmds) do
    hl.exec_cmd(cmd)
  end
end)

------------------
-- local config --
------------------
require("hyprland_local")

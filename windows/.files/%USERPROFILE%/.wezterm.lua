local wezterm = require("wezterm")
local act = wezterm.action

local leader_keys = {
        -- other keys
        { key = "c",      mods = "LEADER|SHIFT",      action = act.ReloadConfiguration},

        --------
        -- PANES
        --------
        { key = "v",      mods = "LEADER",            action = act{SplitVertical={domain="CurrentPaneDomain"}}},
        { key = "v",      mods = "LEADER|CTRL",       action = act{SplitVertical={domain="CurrentPaneDomain"}}},
        -- borizontal 😂
        { key = "b",      mods = "LEADER",            action = act{SplitHorizontal={domain="CurrentPaneDomain"}}},
        { key = "b",      mods = "LEADER|CTRL",       action = act{SplitHorizontal={domain="CurrentPaneDomain"}}},
        { key = "f",      mods = "LEADER",            action = "TogglePaneZoomState" },
        { key = "f",      mods = "LEADER|CTRL",       action = "TogglePaneZoomState" },
        { key = "h",      mods = "LEADER",            action = act{ActivatePaneDirection="Left"}},
        { key = "j",      mods = "LEADER",            action = act{ActivatePaneDirection="Down"}},
        { key = "k",      mods = "LEADER",            action = act{ActivatePaneDirection="Up"}},
        { key = "l",      mods = "LEADER",            action = act{ActivatePaneDirection="Right"}},
        -- { key = "H",    mods = "LEADER|SHIFT",    action = act{ActivatePaneDirection="Left"}},
        -- { key = "J",    mods = "LEADER|SHIFT",    action = act{ActivatePaneDirection="Down"}},
        -- { key = "K",    mods = "LEADER|SHIFT",    action = act{ActivatePaneDirection="Up"}},
        -- { key = "L",    mods = "LEADER|SHIFT",    action = act{ActivatePaneDirection="Right"}},
        -- { key = "1",    mods = "LEADER|SHIFT",    action = wezterm.action_callback(function (win, pane) local tab, window = pane:move_to_new_tab(0) end)},
        -- { key = "2",    mods = "LEADER|SHIFT",    action = wezterm.action_callback(function (win, pane) local tab, window = pane:move_to_new_tab(1) end)},
        -- { key = "3",    mods = "LEADER|SHIFT",    action = wezterm.action_callback(function (win, pane) local tab, window = pane:move_to_new_tab(2) end)},
        -- { key = "4",    mods = "LEADER|SHIFT",    action = wezterm.action_callback(function (win, pane) local tab, window = pane:move_to_new_tab(3) end)},
        -- { key = "5",    mods = "LEADER|SHIFT",    action = wezterm.action_callback(function (win, pane) local tab, window = pane:move_to_new_tab(4) end)},
        -- { key = "6",    mods = "LEADER|SHIFT",    action = wezterm.action_callback(function (win, pane) local tab, window = pane:move_to_new_tab(5) end)},
        -- { key = "7",    mods = "LEADER|SHIFT",    action = wezterm.action_callback(function (win, pane) local tab, window = pane:move_to_new_tab(6) end)},
        -- { key = "8",    mods = "LEADER|SHIFT",    action = wezterm.action_callback(function (win, pane) local tab, window = pane:move_to_new_tab(7) end)},
        -- { key = "9",    mods = "LEADER|SHIFT",    action = wezterm.action_callback(function (win, pane) local tab, window = pane:move_to_new_tab(8) end)},

        -- modes
        { key = "r",      mods = "LEADER",            action = act.ActivateKeyTable { name = 'resize', one_shot = false }},
}

local config = {
    -- use pwsh
    default_prog = {'C:/Program Files/PowerShell/7/pwsh.exe', '-NoExit', '-NoLogo', '-command', 'cls'},
    font = wezterm.font_with_fallback{
      { family = 'MesloLGS NF', weight = 'Regular'},
      'JetBrains Mono',
      'Noto Color Emoji'
    },

    -- appearance
    window_background_opacity = 0.75,
    win32_system_backdrop = 'Acrylic',
    initial_rows = 30,
    initial_cols = 120,
    animation_fps = 15,
    max_fps = 120,
    switch_to_last_active_tab_when_closing_tab = true,
    tab_and_split_indices_are_zero_based = true,
    tab_bar_at_bottom = true,
    use_fancy_tab_bar = false,
    tab_max_width = 30,

    --
    leader = { key="Space", mods="CTRL" },
    disable_default_key_bindings = true,
    keys = {
        { key = 'L',      mods = 'SHIFT|CTRL',        action = act.ShowDebugOverlay },

        -- sensible defaults
        { key = "v",      mods = "SHIFT|CTRL",        action = act.PasteFrom 'Clipboard'},
        { key = "c",      mods = "SHIFT|CTRL",        action = act.CopyTo 'Clipboard'},

        -- non leader keys
        { key = "n",      mods = "SHIFT|CTRL",        action = "ToggleFullScreen" },
        { key = "p",      mods = "SHIFT|CTRL",        action = act.ActivateCommandPalette},
        { key = "w",      mods = "CTRL",              action = act.CloseCurrentPane { confirm = true }},
        { key = "w",      mods = "SHIFT|CTRL",        action = act.CloseCurrentPane { confirm = false }},
        { key = "t",      mods = "CTRL",              action = act{SpawnTab="CurrentPaneDomain"}},

        -------
        -- TABS
        -------
        { key = "1",      mods = "CTRL",              action = act{ActivateTab=0}},
        { key = "2",      mods = "CTRL",              action = act{ActivateTab=1}},
        { key = "3",      mods = "CTRL",              action = act{ActivateTab=2}},
        { key = "4",      mods = "CTRL",              action = act{ActivateTab=3}},
        { key = "5",      mods = "CTRL",              action = act{ActivateTab=4}},
        { key = "6",      mods = "CTRL",              action = act{ActivateTab=5}},
        { key = "7",      mods = "CTRL",              action = act{ActivateTab=6}},
        { key = "8",      mods = "CTRL",              action = act{ActivateTab=7}},
        { key = "9",      mods = "CTRL",              action = act{ActivateTab=8}},
    },

    key_tables = {
      resize = {
        { key = "h",                                  action = act{AdjustPaneSize={"Left", 5}}},
        { key = "j",                                  action = act{AdjustPaneSize={"Down", 5}}},
        { key = "k",                                  action = act{AdjustPaneSize={"Up", 5}}},
        { key = "l",                                  action = act{AdjustPaneSize={"Right", 5}}},
        { key = "h",      mods = "SHIFT",             action = act{AdjustPaneSize={"Right", 5}}},
        { key = "j",      mods = "SHIFT",             action = act{AdjustPaneSize={"Up", 5}}},
        { key = "k",      mods = "SHIFT",             action = act{AdjustPaneSize={"Down", 5}}},
        { key = "l",      mods = "SHIFT",             action = act{AdjustPaneSize={"Left", 5}}},
        { key = 'Escape',                             action = 'PopKeyTable' },
        { key = 'c',      mods = "CTRL",              action = 'PopKeyTable' },
      },
      tmux = {},
      wezterm = {},
    },
}

-- http://lua-users.org/wiki/CopyTable
function shallowcopy(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
      copy = {}
      for orig_key, orig_value in pairs(orig) do
          copy[orig_key] = orig_value
      end
  else -- number, string, boolean, etc
      copy = orig
  end
  return copy
end

-- Add leader events, as well as wezterm key_table workaround
for _, value in ipairs(leader_keys) do
  table.insert(config.keys, shallowcopy(value))

  wezterm.log_info(value)

  local mods = value.mods or ""
  mods = mods:gsub("LEADER", ""):gsub("^|*(.-)|*$", "%1")

  if mods == "" then
    value.mods = nil
  else
    value.mods = mods
  end

  wezterm.log_info(value)

  table.insert(config.key_tables.wezterm, value)
end

wezterm.log_info(config.key_tables.wezterm)

---------
-- EVENTS
---------

wezterm.on('window-config-reloaded', function(window, pane)
  wezterm.log_info 'Configuration reloaded!'
  -- window:toast_notification('wezterm', 'Configuration reloaded!', nil, 1000)
end)

function tab_title(tab_info)
  local title = tab_info.tab_title
  -- if the tab title is explicitly set, take that
  if title and #title > 0 then
    return title
  end
  -- Otherwise, use the title from the active pane
  -- in that tab
  return tab_info.active_pane.title
end

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local prefix = ''
  local suffix = ''
  local title = tab_title(tab)
  local foreground = nil
  local background = nil

  local muxTab = wezterm.mux.get_tab(tab.tab_id)
  local actualPanes = muxTab:panes_with_info()

  for _, pane in ipairs(actualPanes) do 
    if pane.is_zoomed then 
      prefix = '[f] '
      foreground = "#FFFFFF"
      background = '#FCA17D'

      if (tab.is_active) then
        background = "#FF7F4D"
      end
    end
    local panePane
    -- pcall this, since it is possible for .pane to fail try to grab it from mux after we've deleted it
    local status, err = pcall(function() panePane = pane.pane if (panePane:has_unseen_output()) then
      background = "#DA627D"
    end end)
    if not status then
      wezterm.log_info(err)
      goto continue
    end
    -- check if we are in tmux. emit an event
    if (tab.is_active and pane.is_active and panePane) then
      local inTmux = false
      local status, err = pcall(function() inTmux = panePane:get_user_vars()['TMUX'] == "1" and true or false end)
      if not status then
        wezterm.log_info(err)
        goto continue
      end
      if (inTmux) then
        foreground = "#FFFFFF"
        background = "#86BBD8"
      end
    end
    ::continue::
  end

  prefix = " " .. tab.tab_index .. ": " .. prefix 
  suffix = suffix .. " "
  local truncated = wezterm.truncate_right(title, max_width - (string.len(prefix) + string.len(suffix)))
  title = prefix .. (truncated ~= title and (string.sub(truncated, 1, -2) .. "…") or title) .. suffix
  -- title = " " .. (tab.tab_index == tab.tab_id and tab.tab_index or (tab.tab_index .. "#" .. tab.tab_id)) .. ": " .. title .. " "

  local format = {}

  if (foreground ~= nil) then table.insert(format, { Foreground = { Color = foreground } }) end
  if (background ~= nil) then table.insert(format, { Background = { Color = background } }) end
  table.insert(format, { Text = title })

  return format
end)

wezterm.on('format-window-title', function(tab, pane, tabs, panes, config)
  local zoomed = ''
  if tab.active_pane.is_zoomed then
    zoomed = '[🔎] '
  end

  local index = ''
  if #tabs > 1 then
    index = string.format('[%d/%d] ', tab.tab_index + 1, #tabs)
  end

  return zoomed .. index .. tab.active_pane.title
end)

local tmuxPanes = {}

wezterm.on('user-var-changed', function(window, pane, name, value)
  local overrides = window:get_config_overrides() or {}

  -- Handle TMUX
  if (name == "TMUX") then
    local overrides = window:get_config_overrides() or {}
    overrides.keys = overrides.keys or config.keys
    if (window:active_pane():pane_id() == pane:pane_id() and value == "1") then
      if (overrides.leader ~= nil) then return end
      -- If we have TMUX inside a Pane, change the Wezterm Leader key to CTRL+ALT+SPACE
      overrides.leader = { key = "Space", mods = "CTRL|ALT" }

      table.insert(tmuxPanes, { key = pane:pane_id(), pane = pane })
      
      -- Enable a wezterm workaround for anything not on tmux page
      table.insert(overrides.keys, {
        key = "Space", mods = "CTRL", action = act.EmitEvent "check-tmux"
      })

      wezterm.log_warn("[leader] clear")
      window:set_config_overrides(overrides)
    else
      if (overrides.leader == nil) then return end
      overrides.leader = nil
      overrides.keys = config.keys

      for i = #tmuxPanes, 1, -1 do
          if tmuxPanes[i].key == pane:pane_id() then
              table.remove(tmuxPanes, i)
          end
      end

      wezterm.log_warn("[leader] set")
      window:set_config_overrides(overrides)
    end
  end
end)

-- wezterm.on('toggle-wezterm', function(window, pane)
--   local overrides = window:get_config_overrides() or {}
--   if (overrides.leader and overrides.leader.mods == "ALT") then
--     wezterm.log_warn("mode wezterm enabled")
--     overrides.leader = nil
--   else
--     wezterm.log_warn("mode wezterm disabled")
--     overrides.leader = newLeader
--   end
--   window:set_config_overrides(overrides)
-- end)

wezterm.on('check-tmux', function(window, pane)
  wezterm.log_info('foobar')
  if ((function() 
    for _, v in ipairs(tmuxPanes) do
        wezterm.log_info(v)
        if v.key == pane:pane_id() then
            return true
        end
    end
    return false
  end)()) then
    window:perform_action(act.SendString("\x00"), pane)
    window:perform_action(act.ActivateKeyTable { name = 'tmux' }, pane)
  end
  window:perform_action(act.ActivateKeyTable { name = 'wezterm' }, pane)
end)

wezterm.on('update-right-status', function(window, pane)
  local name = window:active_key_table()
  if name then
    name = 'mode: ' .. name
  end
  -- wezterm is a "leader" hack-mode, as such don't display it
  if name == 'wezterm' then
    name = nil
  end 
  window:set_right_status(name or '')
end)

return config

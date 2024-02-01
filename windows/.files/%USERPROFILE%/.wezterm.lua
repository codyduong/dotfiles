local wezterm = require("wezterm")
local act = wezterm.action

local config = {
    -- use pwsh
    default_prog = {'C:/Program Files/PowerShell/7/pwsh.exe', '-NoExit', '-NoLogo', '-command', 'cls'},
    font = wezterm.font_with_fallback{
      { family = 'MesloLGS NF', weight = 'Regular'},
      'JetBrains Mono',
      'Noto Color Emoji'
    },

    -- debug
    -- debug_key_events = true,

    -- appearance
    window_background_opacity = 0.5,
    colors = {
      background = '#000000',
    },

    win32_system_backdrop = 'Disable',
    initial_rows = 30,
    initial_cols = 120,
    animation_fps = 15,
    max_fps = 120,
    switch_to_last_active_tab_when_closing_tab = true,
    tab_and_split_indices_are_zero_based = true,
    tab_bar_at_bottom = true,
    use_fancy_tab_bar = false,
    tab_max_width = 30,

    -- use custom leaders
    leader = { key="_", mods="SHIFT|CTRL|SUPER|ALT" },
    disable_default_key_bindings = true,
    keys = {
        -- shared keys between wezterm/tmux
        { key = 'D',      mods = 'SHIFT|CTRL|ALT',    action = act.ShowDebugOverlay },

        -- sensible defaults
        { key = "v",      mods = "SHIFT|CTRL",        action = act.PasteFrom 'Clipboard'},
        { key = "c",      mods = "SHIFT|CTRL",        action = act.CopyTo 'Clipboard'},
        { key = "-",      mods = "CTRL",              action = act.DecreaseFontSize },
        { key = "=",      mods = "CTRL",              action = act.IncreaseFontSize },

        -- non leader keys
        { key = "n",      mods = "SHIFT|CTRL",        action = "ToggleFullScreen" },
        { key = "p",      mods = "SHIFT|CTRL",        action = act.ActivateCommandPalette},

        -- Dynamic Leader, appriopriately choose wezterm or tmux leader based on active pane
        { key = "Space",  mods = "CTRL",              action = act.EmitEvent "check-tmux" },
        -- Wezterm Leader
        { key = "Space",  mods = "SHIFT|CTRL",        action = act.ActivateKeyTable { name = 'wezterm_leader' } },
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
        { key = 'd',      mods = "CTRL",              action = 'PopKeyTable' },
        { key = 'r',                                  action = 'PopKeyTable' },
      },
      wezterm_leader = {
        { key = "c",      mods = "SHIFT",             action = act.ReloadConfiguration},

        --------
        -- PANES
        --------
        { key = "v",                                  action = act{SplitVertical={domain="CurrentPaneDomain"}}},
        { key = "v",      mods = "CTRL",              action = act{SplitVertical={domain="CurrentPaneDomain"}}},
        -- borizontal 😂
        { key = "b",                                  action = act{SplitHorizontal={domain="CurrentPaneDomain"}}},
        { key = "b",      mods = "CTRL",              action = act{SplitHorizontal={domain="CurrentPaneDomain"}}},
        { key = "f",                                  action = "TogglePaneZoomState" },
        { key = "f",      mods = "CTRL",              action = "TogglePaneZoomState" },
        { key = "h",                                  action = act{ActivatePaneDirection="Left"}},
        { key = "j",                                  action = act{ActivatePaneDirection="Down"}},
        { key = "k",                                  action = act{ActivatePaneDirection="Up"}},
        { key = "l",                                  action = act{ActivatePaneDirection="Right"}},

        -- modes
        { key = "r",                                  action = act.ActivateKeyTable { name = 'resize', one_shot = false }},
      },
      wezterm = {
        { key = "w",      mods = "CTRL",              action = act.CloseCurrentPane { confirm = true }},
        { key = "w",      mods = "SHIFT|CTRL",        action = act.CloseCurrentPane { confirm = false }},
        { key = "t",      mods = "CTRL",              action = act{SpawnTab="CurrentPaneDomain"}},
        { key = "1",      mods = "CTRL",              action = act{ActivateTab=0}},
        { key = "2",      mods = "CTRL",              action = act{ActivateTab=1}},
        { key = "3",      mods = "CTRL",              action = act{ActivateTab=2}},
        { key = "4",      mods = "CTRL",              action = act{ActivateTab=3}},
        { key = "5",      mods = "CTRL",              action = act{ActivateTab=4}},
        { key = "6",      mods = "CTRL",              action = act{ActivateTab=5}},
        { key = "7",      mods = "CTRL",              action = act{ActivateTab=6}},
        { key = "8",      mods = "CTRL",              action = act{ActivateTab=7}},
        { key = "9",      mods = "CTRL",              action = act{ActivateTab=8}},
        { key = "raw:9",  mods = "CTRL",              action = act.ActivateTabRelative(1)},
        { key = "raw:9",  mods = "SHIFT|CTRL",        action = act.ActivateTabRelative(-1)},
      },
      -- typically empty, values are just passed to tmux terminal
      tmux_leader = {},
      tmux = {
        { key = "w",      mods = "CTRL",              action = act.SendString("\x17")},
        { key = "t",      mods = "CTRL",              action = act.SendString("\x14")},
        { key = "1",      mods = "CTRL",              action = act.Multiple{ act.SendKey { key = "1", mods = 'CTRL' } }},
        { key = "2",      mods = "CTRL",              action = act.Multiple{ act.SendKey { key = "2", mods = 'CTRL' } }},
        { key = "3",      mods = "CTRL",              action = act.Multiple{ act.SendKey { key = "3", mods = 'CTRL' } }},
        { key = "4",      mods = "CTRL",              action = act.Multiple{ act.SendKey { key = "4", mods = 'CTRL' } }},
        { key = "5",      mods = "CTRL",              action = act.Multiple{ act.SendKey { key = "5", mods = 'CTRL' } }},
        { key = "6",      mods = "CTRL",              action = act.Multiple{ act.SendKey { key = "6", mods = 'CTRL' } }},
        { key = "7",      mods = "CTRL",              action = act.Multiple{ act.SendKey { key = "7", mods = 'CTRL' } }},
        { key = "8",      mods = "CTRL",              action = act.Multiple{ act.SendKey { key = "8", mods = 'CTRL' } }},
        { key = "9",      mods = "CTRL",              action = act.Multiple{ act.SendKey { key = "9", mods = 'CTRL' } }},

        -- enter the escape mode to use wezterm non leader commands
        -- CTRL+SHIFT+~
        { key = "raw:192",mods = "SHIFT|CTRL",        action = act.ActivateKeyTable { name = 'tmux_escape' } },
      },
      tmux_escape = {
        -- used to get back to wezterm
        { key = "w",                                  action = act.CloseCurrentPane { confirm = true }},
        { key = "t",                                  action = act{SpawnTab="CurrentPaneDomain"}},
        { key = "1",                                  action = act{ActivateTab=0}},
        { key = "2",                                  action = act{ActivateTab=1}},
        { key = "3",                                  action = act{ActivateTab=2}},
        { key = "4",                                  action = act{ActivateTab=3}},
        { key = "5",                                  action = act{ActivateTab=4}},
        { key = "6",                                  action = act{ActivateTab=5}},
        { key = "7",                                  action = act{ActivateTab=6}},
        { key = "8",                                  action = act{ActivateTab=7}},
        { key = "9",                                  action = act{ActivateTab=8}},

        { key = 'Escape',                             action = 'PopKeyTable' },
        { key = 'c',      mods = "CTRL",              action = 'PopKeyTable' },
        { key = 'd',      mods = "CTRL",              action = 'PopKeyTable' },
      }
    },
}

-- Generate the generic key press to route to wezterm or tmux
for _, value in ipairs(config.key_tables.wezterm) do
  table.insert(config.keys, {
    key = value.key, mods = value.mods, action = act.EmitEvent("check-tmux-nolead-" .. value.mods .. "+" .. value.key)
  })
end
for _, value in ipairs(config.key_tables.tmux) do
  local isUnique = true

  for _, value2 in ipairs(config.keys) do
    if (value.key == value2.key) and (value.mods == value2.mods) then
      isUnique = false
    end
  end

  if (isUnique) then
    table.insert(config.keys, {
      key = value.key, mods = value.mods, action = act.EmitEvent("check-tmux-nolead-" .. value.mods .. "+" .. value.key)
    })
  end
end

---------
-- EVENTS
---------

local tmuxPanes = {}

wezterm.on('window-config-reloaded', function(window, pane)
  wezterm.log_info 'Configuration reloaded!'
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
    -- check if we are in tmux
    if (panePane) then
      local inTmux = false
      local status, err = pcall(function() inTmux = panePane:get_user_vars()['TMUX'] == "1" and true or false end)
      if not status then
        goto continue
      end
      if (inTmux) then
        foreground = "#FFFFFF"
        background = "#86BBD8"
        -- it is possible that we accidentally refreshed the config, in this case add back tmuxPane
        local paneId = panePane:pane_id()
        if (not is_in_tmux_pane(paneId)) then
          wezterm.log_info("Found orphaned tmux pane: " .. paneId .. ", adding back!")
          tmuxPanes[paneId] = panePane
        end
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

wezterm.on('user-var-changed', function(window, pane, name, value)
  local overrides = window:get_config_overrides() or {}

  if (name == "TMUX") then
    tmuxPanes[pane:pane_id()] = pane
  end
end)

function is_in_tmux_pane(pane_id)
  return tmuxPanes[pane_id] ~= nil
end

wezterm.on('check-tmux', function(window, pane)
  if is_in_tmux_pane(pane:pane_id()) then
    window:perform_action(act.SendString("\x00"), pane)
    window:perform_action(act.ActivateKeyTable { name = 'tmux_leader' }, pane)
  else
    window:perform_action(act.ActivateKeyTable { name = 'wezterm_leader' }, pane)
  end
end)

-- dynamically generate a bunch of events
for _, value in ipairs(config.keys) do
  wezterm.on("check-tmux-nolead-" .. value.mods .. "+" .. value.key, function(window, pane)
    if is_in_tmux_pane(pane:pane_id()) then
      wezterm.log_info("using tmux action: " .. value.mods .. "+" .. value.key)
      -- attempt to find the tmux action
      local tmux_action = (function()
        for _, value2 in ipairs(config.key_tables.tmux) do
          if (value2.key == value.key) and (value2.mods == value.mods) then
            return value2.action
          end
        end
        return nil
      end)() or value.action
      if tmux_action then
        window:perform_action(tmux_action, pane)
      else
        wezterm.log_warn("unable to find tmux action")
      end
    else
      wezterm.log_info("using wezterm action: " .. value.mods .. "+" .. value.key)
      -- attempt to find the wezterm action
      local wezterm_action = (function()
        for _, value2 in ipairs(config.key_tables.wezterm) do
          if (value2.key == value.key) and (value2.mods == value.mods) then
            return value2.action
          end
        end
        return nil
      end)() or value.action
      if wezterm_action then
        window:perform_action(wezterm_action, pane)
      else
        wezterm.log_warn("unable to find wezterm action")
      end
    end
  end)
end

wezterm.on('update-right-status', function(window, pane)
  local name = window:active_key_table()
  if name then
    name = 'mode: ' .. name
  end

  if is_in_tmux_pane(pane:pane_id()) then
    window:set_right_status('mode: tmux')
  end

  window:set_right_status(name or '')
end)

return config

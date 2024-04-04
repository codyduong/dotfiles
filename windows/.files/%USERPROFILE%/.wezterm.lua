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
    window_background_opacity = 0.75,
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
    adjust_window_size_when_changing_font_size = false,

    -- use custom leaders
    leader = { key="_", mods="SHIFT|CTRL|SUPER|ALT" },
    disable_default_key_bindings = true,
    keys = {
        -- shared keys between wezterm/tmux
        { key = 'D',      mods = 'SHIFT|CTRL|ALT',    action = act.ShowDebugOverlay },

        -- sensible defaults
        { key = "v",      mods = "SHIFT|CTRL",        action = act.PasteFrom 'Clipboard'},
        { key = "c",      mods = "SHIFT|CTRL",        action = act.CopyTo 'Clipboard'},
        { key = "-",      mods = "CTRL",              action = act.Multiple{ act.EmitEvent "disable-unseen-temp", act.DecreaseFontSize }},
        { key = "=",      mods = "CTRL",              action = act.Multiple{ act.EmitEvent "disable-unseen-temp", act.IncreaseFontSize }},
        { key = "0",      mods = "CTRL",              action = act.Multiple{ act.EmitEvent "disable-unseen-temp", act.ResetFontSize }},

        -- non leader keys
        { key = "n",      mods = "SHIFT|CTRL",        action = "ToggleFullScreen" },
        { key = "p",      mods = "SHIFT|CTRL",        action = act.ActivateCommandPalette},
        { key = "t",      mods = "SHIFT|CTRL",        action = act.ShowTabNavigator },

        -- Dynamic Leader, appriopriately choose wezterm or tmux leader based on active pane
        { key = "Space",  mods = "CTRL",              action = act.EmitEvent "check-pane" },
        -- Wezterm Leader
        { key = "Space",  mods = "SHIFT|CTRL",        action = act.ActivateKeyTable { name = 'wezterm_leader' } },
    },
    key_tables = {
      resize = {
        { key = 'Escape',                             action = 'PopKeyTable' },
        { key = 'c',      mods = "CTRL",              action = 'PopKeyTable' },
        { key = 'd',      mods = "CTRL",              action = 'PopKeyTable' },
        { key = 'r',                                  action = 'PopKeyTable' },

        { key = "h",                                  action = act{AdjustPaneSize={"Left", 5}}},
        { key = "j",                                  action = act{AdjustPaneSize={"Down", 5}}},
        { key = "k",                                  action = act{AdjustPaneSize={"Up", 5}}},
        { key = "l",                                  action = act{AdjustPaneSize={"Right", 5}}},
        { key = "h",      mods = "SHIFT",             action = act{AdjustPaneSize={"Right", 5}}},
        { key = "j",      mods = "SHIFT",             action = act{AdjustPaneSize={"Up", 5}}},
        { key = "k",      mods = "SHIFT",             action = act{AdjustPaneSize={"Down", 5}}},
        { key = "l",      mods = "SHIFT",             action = act{AdjustPaneSize={"Left", 5}}},
      },
      wezterm_leader = {
        { key = 'Escape',                             action = 'PopKeyTable' },
        { key = 'c',      mods = "CTRL",              action = 'PopKeyTable' },
        { key = 'd',      mods = "CTRL",              action = 'PopKeyTable' },
        { key = 'Space',  mods = "CTRL",              action = 'PopKeyTable' },
        { key = "Space",  mods = "SHIFT|CTRL",        action = 'PopKeyTable' },

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
        -- CTRL+TAB and CTRL+SHIFT+TAB to cycle
        { key = "raw:9",  mods = "CTRL",              action = act.ActivateTabRelative(1)},
        { key = "raw:9",  mods = "SHIFT|CTRL",        action = act.ActivateTabRelative(-1)},

        { key = "j",      mods = "CTRL",              action = act.ScrollByLine(-1) },
        { key = "k",      mods = "CTRL",              action = act.ScrollByLine(1) },
        { key = "e",      mods = "CTRL",              action = act.EmitEvent "scroll-half-up" },
        { key = "d",      mods = "CTRL",              action = act.EmitEvent "scroll-half-down" },
      },
      -- typically empty, values are just passed to tmux terminal
      tmux_leader = {},
      tmux = {
        { key = "w",      mods = "CTRL",              action = act.SendString("\x17")},
        { key = "t",      mods = "CTRL",              action = act.SendString("\x14")},
        { key = "1",      mods = "CTRL",              action = act.SendKey{ key = "1", mods = 'CTRL' }},
        { key = "2",      mods = "CTRL",              action = act.SendKey{ key = "2", mods = 'CTRL' }},
        { key = "3",      mods = "CTRL",              action = act.SendKey{ key = "3", mods = 'CTRL' }},
        { key = "4",      mods = "CTRL",              action = act.SendKey{ key = "4", mods = 'CTRL' }},
        { key = "5",      mods = "CTRL",              action = act.SendKey{ key = "5", mods = 'CTRL' }},
        { key = "6",      mods = "CTRL",              action = act.SendKey{ key = "6", mods = 'CTRL' }},
        { key = "7",      mods = "CTRL",              action = act.SendKey{ key = "7", mods = 'CTRL' }},
        { key = "8",      mods = "CTRL",              action = act.SendKey{ key = "8", mods = 'CTRL' }},
        { key = "9",      mods = "CTRL",              action = act.SendKey{ key = "9", mods = 'CTRL' }},

        -- enter the escape mode to use wezterm non leader commands
        -- CTRL+SHIFT+~
        { key = "raw:192",mods = "SHIFT|CTRL",        action = act.ActivateKeyTable { name = 'tmux_escape' } },
      },
      tmux_escape = {
        -- used to get back to wezterm
        -- the key/value pairs are a copy of config.key_tables.wezterm except these VVV
        { key = 'Escape',                             action = 'PopKeyTable' },
        { key = 'c',      mods = "CTRL",              action = 'PopKeyTable' },
        { key = 'd',      mods = "CTRL",              action = 'PopKeyTable' },
      },
      nvim_leader = {},
      nvim = {
        { key = "j",      mods = "CTRL",              action = act.SendKey{ key = "j", mods = 'CTRL' }},
        { key = "k",      mods = "CTRL",              action = act.SendKey{ key = "k", mods = 'CTRL' }},
        { key = "e",      mods = "CTRL",              action = act.SendKey{ key = "e", mods = 'CTRL' }},
        { key = "d",      mods = "CTRL",              action = act.SendKey{ key = "d", mods = 'CTRL' }},
      }
    },
}

--------------
-- COMMON VARS
--------------
-- check for specific processes running in a pane
local tmuxPanes = {}
local nvimPanes = {}
-- suppress update notifier by storing the latest line and checking if it has changed
local panesLogicalText = {}
-- increments for various tabIds
local tabIncrements = {} -- key: tab_id(), value: 0->max_width of process - substring max

-- last run for ease of tracking
local lastRun = {"N/A", "", ""}

--------
-- TABLE
--------

-- Generate the generic key press to route to wezterm or tmux
for _, value in ipairs(config.key_tables.wezterm) do
  table.insert(config.keys, {
    key = value.key, mods = value.mods, action = act.EmitEvent("check-nolead-" .. value.mods .. "+" .. value.key)
  })
  table.insert(config.key_tables.tmux_escape, {
    key = value.key, mods = value.mods, action = value.action
  })
end
for _, value in ipairs(config.key_tables.tmux) do
  local isUnique = true

  for _, value2 in ipairs(config.keys) do
    if (value.key == value2.key) and (value.mods == value2.mods) then
      isUnique = false
      break
    end
  end

  if (isUnique) then
    table.insert(config.keys, {
      key = value.key, mods = value.mods, action = act.EmitEvent("check-nolead-" .. value.mods .. "+" .. value.key)
    })
  end
end
for _, value in ipairs(config.key_tables.nvim) do
  local isUnique = true

  for _, value2 in ipairs(config.keys) do
    if (value.key == value2.key) and (value.mods == value2.mods) then
      isUnique = false
      break
    end
  end

  if (isUnique) then
    table.insert(config.keys, {
      key = value.key, mods = value.mods, action = act.EmitEvent("check-nolead-" .. value.mods .. "+" .. value.key)
    })
  end
end

-- Multikey the leader keys so we can send it to lastKey
for k, value in pairs(config.key_tables) do
  if (string.match(k, "_leader")) then
    config.key_tables[k] = {}
    for _, value2 in ipairs(value) do
      local key, mods, action = value2.key, value2.mods, value2.action
      local event = "emit-"..(mods or "").."+"..key
      table.insert(config.key_tables[k], {
        key = key,
        mods = mods,
        -- action = action
        action = act.Multiple {
          wezterm.action_callback(function(window, pane)
            lastRun = {k, mods or "", key}
          end),
          action
        }
      })
    end
  end
  -- TODO also add escape
end

---------
-- EVENTS
---------

local function basename(s)
  return string.gsub(s, '(.*[/\\])(.*)', '%2')
end

local function is_in_tmux_pane(pane_id)
  return tmuxPanes[pane_id] ~= nil
end

local function is_in_nvim_pane(process)
  local pname = process:get_foreground_process_name()
  if pname ~= nil then
    local base = basename(pname)
    return string.match(base, "vim")
  end
  return false
end

wezterm.on('window-config-reloaded', function(window, pane)
  wezterm.log_info 'Configuration reloaded!'
end)

local function tab_title(tab_info)
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
    local status, err = pcall(function() panePane = pane.pane end)
    -- If we change fontsize or any other action that modifies lines but not logically, don't mark as updated
    if (
      panePane ~= nil and
      -- TODO, some programs that should provide update use this altscreen char and so we need to find alternative way
      -- (panePane:is_alt_screen_active() ~= true) and -- nvim/less shouldn't have updates to report, this is just logical line change
      panesLogicalText[panePane:pane_id()] ~= panePane:get_logical_lines_as_text(2)
      and panePane:has_unseen_output()
      -- panePane:has_unseen_output()
    ) then
      -- this works OK for increase/decrease font size in plain terminals, subterminals like nvim will still fail
      background = "#DA627D"
    end
    if not status then
      wezterm.log_info(err)
      goto continue
    end
    -- check if we are in tmux
    if (panePane) then
      local inTmux = false
      local status, err = pcall(function() inTmux = panePane:get_user_vars()['TMUX'] == "1" and true or false end)
      if not status then
        wezterm.log_warn(err)
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

  prefix = " " .. tab.tab_index+1 .. ": " .. prefix
  suffix = suffix .. " "

  local recalculated_max = max_width-(string.len(prefix)+string.len(suffix)+1)
  local truncated = string.sub(title, 1, 1+recalculated_max)
  local actually_truncated = truncated ~= title
  if actually_truncated then
    local tabIncrement = tabIncrements[tab.tab_id] or 0
    local incrementAdjusted = math.max(0, (tabIncrement-5))//10
    if hover then
      local speed = 2
      if (recalculated_max + incrementAdjusted >= string.len(title) + 5) then
        tabIncrements[tab.tab_id] = 0
      else
        tabIncrements[tab.tab_id] = tabIncrement+speed
      end
    end
    truncated = string.sub(title, math.min(string.len(title)-recalculated_max,1+incrementAdjusted), recalculated_max+incrementAdjusted)
    if (recalculated_max + incrementAdjusted >= string.len(title)) then
      title = prefix .. truncated .. suffix
    else 
      title = prefix .. (string.sub(truncated, 1, -1) .. "…") .. suffix
    end
  else
    title = prefix .. (actually_truncated and (string.sub(truncated, 1, -1) .. "…") or title) .. suffix
  end

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
  local paneId = pane:pane_id()

  if (name == "TMUX" and value == "1") then
    tmuxPanes[paneId] = pane
    return
  elseif (name == "TMUX") then
    tmuxPanes[paneId] = nil
    return
  end

  -- TODO: use this for nvim inside of wsl
  -- if (name == "NVIM" and value == "1") then
  --   nvimPanes[paneId] = pane
  --   return
  -- elseif  (name == "NVIM") then
  --   nvimPanes[paneId] = nil
  --   return
  -- end
end)

wezterm.on('check-pane', function(window, pane)
  local paneId = pane:pane_id()
  if is_in_nvim_pane(pane) then
    window:perform_action(act.ActivateKeyTable { name = 'nvim_leader' }, pane)
  elseif is_in_tmux_pane(paneId) then
    -- by default suppress key presses
    window:perform_action(act.SendString("\x00"), pane)
    window:perform_action(act.ActivateKeyTable { name = 'tmux_leader' }, pane)
  else
    window:perform_action(act.ActivateKeyTable { name = 'wezterm_leader' }, pane)
  end
end)

-- dynamically generate a bunch of events
for _, value in ipairs(config.keys) do
  local actionstr = value.mods .. "+" .. value.key
  wezterm.on("check-nolead-" .. value.mods .. "+" .. value.key, function(window, pane)
    lastRun = {"", value.mods, value.key}
    if is_in_nvim_pane(pane) then
      wezterm.log_info("attempting nvim action: " .. value.mods .. "+" .. value.key)
      -- attempt to find the nvim action
      local nvim_action = (function()
        for _, value2 in ipairs(config.key_tables.nvim) do
          if (value2.key == value.key) and (value2.mods == value.mods) then
            return value2.action
          end
        end
        return nil
      end)()
      if nvim_action then
        wezterm.log_info("using nvim action: " .. actionstr)
        lastRun[1] = "nvim"
        window:perform_action(nvim_action, pane)
        return
      else
        wezterm.log_warn("unable to find nvim action")
      end
    end

    if is_in_tmux_pane(pane:pane_id()) then
      wezterm.log_info("attempting tmux action: " .. actionstr)
      -- attempt to find the tmux action
      local tmux_action = (function()
        for _, value2 in ipairs(config.key_tables.tmux) do
          if (value2.key == value.key) and (value2.mods == value.mods) then
            return value2.action
          end
        end
        return nil
      end)()
      if tmux_action then
        wezterm.log_info("using tmux action: " .. actionstr)
        lastRun[1] = "tmux"
        window:perform_action(tmux_action, pane)
        return
      else
        wezterm.log_warn("unable to find tmux action")
      end
    end

    -- attempt to find the wezterm action
    wezterm.log_info("attempting wezterm action: " .. actionstr)
    local wezterm_action = (function()
      for _, value2 in ipairs(config.key_tables.wezterm) do
        if (value2.key == value.key) and (value2.mods == value.mods) then
          return value2.action
        end
      end
      return nil
    end)()
    if wezterm_action then
      wezterm.log_info("using wezterm action: " .. actionstr)
      lastRun[1] = "wezterm"
      window:perform_action(wezterm_action, pane)
      return
    else
      wezterm.log_warn("unable to find wezterm action")
    end
    
    wezterm.log_info("using default action: " .. actionstr)
    -- this can cause infinite loops if we are not careful... notably we should exhaust all options above
    -- window:perform_action(value.action)
  end)
end

wezterm.on('update-right-status', function(window, pane)
  local cells = {}

  local LEFT_ARROW = utf8.char(0xe0b3)
  local SOLID_LEFT_ARROW = utf8.char(0xe0b2)

  local colors = {
    -- https://github.com/JanDeDobbeleer/oh-my-posh/blob/main/themes/M365Princess.omp.json
    white = "#FFFFFF",
    tan = "#CC3802",  
    teal = "#047E84",  
    plum = "#9A348E",  
    blush = "#DA627D",  
    salmon = "#FCA17D",  
    sky = "#86BBD8",  
    teal_blue = "#33658A"   
  }
  local text_fg = '#FFFFFF'

  -- last key pressed
  
  local mods, key  = lastRun[2], lastRun[3]
  mods = mods:gsub("|", ""):gsub("CTRL", "C"):gsub("SHIFT", "S")

  -- ⍰ Mode
  -- local PLACEHOLDER = utf8.char(9072)

  wezterm.log_info(mods .. key)
  local key_table = window:active_key_table()
  local name = key_table or lastRun[1] or ""
  name = string.gsub(name, "_leader", "+")
  table.insert(cells, {Foreground = { Color = text_fg }})
  local isPlussed = string.match(name, "+")
  name = (isPlussed and name or (name.." "))

  if not key_table then
    -- vim like
    table.insert(cells, {Background = { Color = colors['teal'] }})
    table.insert(cells, {
      Text = " M: " .. wezterm.pad_left('NORMAL', 14) .. " "
    })
  end
    
  if key_table then
    -- vim like
    if (key_table == 'resize') then
      table.insert(cells, {Background = { Color = colors['teal'] }})
      table.insert(cells, {
        Text = " M: " .. wezterm.pad_left('RESIZE', 14) .. " "
      })
    end

    table.insert(cells, {Background = { Color = colors['teal'] }})
    table.insert(cells, {
      Text = " M: " .. wezterm.pad_left(name, 14) .. " "
    })
    
    table.insert(cells, {Background = { Color = colors['teal_blue'] }})
    table.insert(cells, {
      Text = " L: " .. wezterm.pad_left(name .. mods .. (mods ~= "" and "-" or "") .. key, 14) .. " "
    })
  elseif isPlussed then
    table.insert(cells, {Background = { Color = colors['teal_blue'] }})
    table.insert(cells, {
      Text = " L: " .. wezterm.pad_left(name .. mods .. (mods ~= "" and "-" or "") .. key, 14) .. " "
    })
  else
    table.insert(cells, {Background = { Color = colors['teal_blue'] }})
    table.insert(cells, {
      Text = " N: " .. wezterm.pad_left(name .. mods .. (mods ~= "" and "-" or "") .. key, 14) .. " "
    })
  end

  window:set_right_status(wezterm.format(cells))
end)

wezterm.on('scroll-half-up', function(window, pane)
  local dims = pane:get_dimensions()
  local rows = dims.viewport_rows
  for _ = 1, rows//2, 1 do
    wezterm.sleep_ms(1)
    window:perform_action(act.ScrollByLine(-1), pane)
  end
end)

wezterm.on('scroll-half-down', function(window, pane)
  local dims = pane:get_dimensions()
  local rows = dims.viewport_rows
  for _ = 1, rows//2, 1 do
    wezterm.sleep_ms(1)
    window:perform_action(act.ScrollByLine(1), pane)
  end
end)

wezterm.on('disable-unseen-temp', function(window, pane)
  local tabs = window:mux_window():tabs_with_info()
  -- Iterate through all tabs/panes and store their latest text
  for _, tab in ipairs(tabs) do
    for _, pane2 in ipairs(tab.tab:panes_with_info()) do
      panesLogicalText[pane2.pane:pane_id()] = pane2.pane:get_logical_lines_as_text(2)
    end
  end
  -- for k, p in ipairs(panesLogicalText) do
  --   wezterm.log_info(p)
  -- end
end)

return config

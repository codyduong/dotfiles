local monitors = hitokage.monitor.get_all()

--- @type BarArray
local bars = {}

local reactive_labels = {}
local reactive_imgs = {}

local clock_icons = {
  "\u{F144A}",
  "\u{F143F}",
  "\u{F1440}",
  "\u{F1441}",
  "\u{F1442}",
  "\u{F1443}",
  "\u{F1444}",
  "\u{F1445}",
  "\u{F1446}",
  "\u{F1447}",
  "\u{F1448}",
  "\u{F1449}",
}

--- @type table<number, ReactiveString>
local reactive_clock_icons = {}

for _, monitor in ipairs(monitors) do
  if monitor.model == "LG SDQHD" then
    goto continue
  end

  -- TODO better idiomatic syntax
  -- monitor.create_bar({
  --   widgets = {
  --     {Workspace = {}},
  --     {Clock = {format = "%Y-%m-%d %H:%M:%S"}},
  --     {Box = {}},
  --   }
  -- })

  -- the unsafe operation occurs in creating reactives in lua. this has to do with how we serialize data...
  local reactive_label = hitokage.unstable.reactive.create("foo \u{EECB}")
  local reactive_img = hitokage.unstable.reactive.create("./smiley.png")
  local reactive_clock_icon = hitokage.unstable.reactive.create(clock_icons[tonumber(os.date("%H")) % 12 + 1])

  table.insert(reactive_labels, reactive_label)
  table.insert(reactive_imgs, reactive_img)
  table.insert(reactive_clock_icons, reactive_clock_icon)

  local mem_str =
  '{{pad "left" (round (div used 1024) 1) 4}} ({{ pad "left" (concat (round (mult (div used total) 100) 1) "%") 4 }})'
  local cpu_str = '{{pad "left" (concat (round (mult usage 100) 1) "%") 6}}'

  -- .. 'C1: {{pad "right" (concat (round (mult core1_usage 100) 1) "%") 6}}'
  -- .. 'C1: {{pad "right" (concat (round (mult core1_usage 100) 1) "%") 6}}'
  -- .. 'C2: {{pad "right" (concat (round (mult core2_usage 100) 1) "%") 6}}'
  -- .. 'C3: {{pad "right" (concat (round (mult core3_usage 100) 1) "%") 6}}'
  -- .. 'C4: {{pad "right" (concat (round (mult core4_usage 100) 1) "%") 6}}'
  -- .. 'C5: {{pad "right" (concat (round (mult core5_usage 100) 1) "%") 6}}'
  -- .. 'C6: {{pad "right" (concat (round (mult core6_usage 100) 1) "%") 6}}'
  -- .. 'C7: {{pad "right" (concat (round (mult core7_usage 100) 1) "%") 6}}'

  table.insert(
    bars,
    monitor:attach({
      children = {
        {
          Box = {
            halign = 'Start',
            hexpand = true,
            children = {
              {
                Box = {
                  class = "left bar-group",
                  halign = "Start",
                  children = {
                    { Workspace = { halign = "Start", item_height = 24, item_width = 24, format = "{{add index 1}}" } },
                  }
                }
              },
              -- { Label = { label = "\u{E0B4}", class = "bar-group-extra" } },
            }
          }
        },
        {
          Box = {
            halign = 'Center',
            hexpand = true,
            children = {
              -- { Label = { label = "\u{E0B6}", class = "bar-group-extra fix-spacing" } },
              {
                Box = {
                  homogeneous = false,
                  class = "center bar-group",
                  children = {
                    {
											Weather = {
												class = "icon",
												latitude = 38.95773795883854,
												longitude = -95.25382422045898,
												format = "{{icon}}",
											},
										},
										{ Weather = { class = "data", format = "{{temp_fahrenheit}} °F" } },
                    { Label = { class = "icon clock date", label = "\u{F00ED}", } },
                    { Clock = { class = "data", format = "%a %b %e", halign = "End" } },
                    { Label = { class = "icon clock", label = reactive_clock_icon, } },
                    { Clock = { class = "data", format = "%r", halign = "End" } },
                  }
                }
              },
              -- { Label = { label = "\u{E0B4}", class = "bar-group-extra" } },
            }
          }
        },
        {
          Box = {
            halign = 'End',
            hexpand = true,
            children = {
              {
                Box = {
                  halign = 'End',
                  hexpand = true,
                  children = {
                    -- { Label = { halign = "End", label = "\u{E0B6}", class = "bar-group-extra" } },
                    {
                      Box = {
                        halign = "End",
                        class = "right bar-group",
                        children = {
                          { Label = { class = "icon memory", label = "\u{EFC5}", } },
                          { Memory = { class = "data", format = mem_str, halign = "End" } },
                          { Label = { class = "icon", label = "\u{F4BC}" } },
                          { Cpu = { class = "data", format = cpu_str, halign = "End" } },
                        },
                      }
                    },
                  }
                }
              },
            }
          }

        },
      },
      homogeneous = true,
    })
  )
  ::continue::
end

--- @alias WorkspaceTable table<number, Workspace>
--- @type WorkspaceTable
local workspaces = {}

for i, bar in ipairs(bars) do
  while not bar:is_ready() do
    hitokage.debug("waiting for bar to instantiate", i)
    coroutine.yield() -- yield to other processes to occur
  end
  for _, child in ipairs(bar:get_children()) do
    hitokage.debug(child)
    if child.type == "Clock" then
      table.insert(clocks, child)
    end
  end
end

local update_clock_icon = hitokage.timeout(1000, function()
  for _, clock_icon in ipairs(reactive_clock_icons) do
    local hour_24 = tonumber(os.date("%H"))
    local hour_12 = hour_24 % 12
    clock_icon:set(clock_icons[hour_12 + 1])
  end
end)

hitokage.dispatch(update_clock_icon)

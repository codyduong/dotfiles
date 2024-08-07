local monitors = hitokage.monitor.get_all()

--- @type BarArray
local bars = {}

for _, monitor in ipairs(monitors) do
  if (monitor.model == "LG SDQHD") then
    goto continue
  end

  table.insert(bars, hitokage.bar.create(monitor, {
    widgets = {
      { Box = {} },
      { Workspace = { halign = "Center", item_height = 22, item_width = 22 } },
      { Clock = { format = "%a %b %u %r", halign = 'End' } },
    },
    width = monitor.geometry.width - 16,
    offset = {
      x = 8,
      y = 8,
    }
  }))
  ::continue::
end

hitokage.debug(hitokage);

local monitors = hitokage.monitor.get_all()
local primary = hitokage.monitor.get_primary()

hitokage.debug(monitors)

local bars = {}
for index, monitor in ipairs(monitors) do
  if (monitor.model == "LG SDQHD") then
    goto continue
  end

  table.insert(bars, hitokage.bar.create({
    monitor = index - 1,
    geometry = monitor.geometry,
    widgets = {
      {Workspace = {}},
      {Clock = {format = "%Y-%m-%d %H:%M:%S"}},
      {Box = {}},
    },
    scale_factor = monitor.scale_factor,
    id = monitor.id
  }))
  ::continue::
end
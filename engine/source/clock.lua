local Clock = class('Clock', Base)

function Clock:default()
  self:set('elapsed_time', 0)
  self:set('time_scale', 1)
end

function Clock:tick(raw_delta_time)
  local new_time = (self:elapsed_time() + raw_delta_time) * self:time_scale()
  self:set('elapsed_time', new_time)

  local new_delta = raw_delta_time * self:time_scale()
  self:set('delta_time', new_delta)
end

return Clock:builder()

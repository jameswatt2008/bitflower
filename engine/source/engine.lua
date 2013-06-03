require('color')

local Engine = class('Engine', Base)

function Engine:default()
  self:load_and_set('stage')
  self:load_and_set('stem_server')

  self:set('clocks', {})

  self:set('elapsed_ticks', 0)

  self:attach_clock('primary', {
    elapsed_time = 0,
    time_scale = 1
  })
end

function Engine:change_scene(scene_name)
  self:stage():activate(scene_name)
end

function Engine:attach_clock(name, clock_state)
  self:clocks()[name] = self:load('clock', clock_state)
end

function Engine:primary_clock()
  return self:clocks()['primary']
end

function Engine:elapsed_time()
  return self:primary_clock():elapsed_time()
end

function Engine:delta_time()
  return self:clock():delta_time()
end

function Engine:tick(raw_dt)
  self:set('elapsed_ticks', self:elapsed_ticks() + 1)

  for _, clock in pairs(self:clocks()) do
    clock:tick(raw_dt)
  end

  self:stage():active_scene():update()
end

function Engine:set_tick_rate(new_rate)
  self:set('tick_rate', new_rate)
  bitflower.set_native_tick_rate(new_rate)
end

function Engine:input_event(raw_event)
  self:stage():active_scene():input_event(raw_event)
end

return Engine:builder()


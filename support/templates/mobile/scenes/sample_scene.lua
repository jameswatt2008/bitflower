-- this is the sample scene that comes pre-loaded with new projects

local Scene  = require('scene')
local SampleScene = class('SampleScene', Scene)

function SampleScene:load_assets()
end

function SampleScene:start()
  bitflower.gl.clear({r=0, g=255, b=255,a=1})
end

function SampleScene:update()
  local color = Color:new(0, 
    math.abs(255 * math.sin(engine:elapsed_time() / 1000)), 
    255,
    1)

  bitflower.gl.clear(color:raw())
end

function SampleScene:input_event(event)
end

function SampleScene:exit()
end

function SampleScene:unload_assets()
end

return SampleScene:builder()

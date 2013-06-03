local Scene = class('Scene', Base)

function Scene:load_assets()
  self:not_defined('load_assets', 'Scene')
end

function Scene:start()
  self:not_defined('start', 'Scene')
end

function Scene:update()
  self:not_defined('update', 'Scene')
end

function Scene:input_event(raw_event)
  self:not_defined('input_event', 'Scene')
end

function Scene:exit()
  self:not_defined('exit', 'Scene')
end

function Scene:unload_assets()
  self:not_defined('unload_assets', 'Scene')
end

return Scene

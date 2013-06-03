local Stage = class('Stage', Base)

function Stage:default()
  self:set('scenes', {})
end

function Stage:activate(scene_name, purge)
  if not self:scenes()[scene_name] then
    self:scenes()[scene_name] = self:load(scene_name)
  end

  self:set('active_scene', self.state.scenes[scene_name])
  self:active_scene():load_assets()
  self:active_scene():start()

  if purge then
    for name, scene in pairs(self:scenes()) do
      if name ~= scene_name then
        scene:unload_assets()
        self:scenes()[name] = nil
        scene = nil
      end
    end
  end
end

return Stage:builder()

require('middleclass')

Base = class('Base')

function Base:initialize(loader, state)
  self.loader = loader
  self.loaded = {}

  self.state = {}

  if state then
    for k,v in pairs(state) do
      self:set(k, v)
    end
  elseif not state and self.default then
    self:default()
  end 
end

function Base:load(name, state, data)
  if not self.loaded[name] then
    self.loaded[name] = {}
  end

  local mod
  if not data then
    mod = require(name)(self, state)
    assert(mod, 'The `' .. name .. '` module could not be loaded/found!')
  else
    local modpackage, err = loadstring(data, name)
    if not err then
      package.loaded[name] = modpackage
      mod = modpackage(self, state)
      -- engine:stem_server():state_load_success(name)
    else
      -- engine:stem_server():state_load_failure(name, err)
    end
  end

  table.insert(self.loaded[name], mod)

  return mod
end

function Base:reload(name, data)
  -- if we have this mod, reload it
  if self.loaded[name] then
    package.loaded[name] = nil

    for i, mod in ipairs(self.loaded[name]) do
      -- go through our state and save the key if it references this mod,
      -- so that we can later change it to reference the reloaded version
      local saved = {}
      for k, v in pairs(self.state) do
        if v == mod then
          saved[#saved] = k
        end
      end
      
      local mod_state = mod.state
      self.loaded[name][i] = self:load(name, mod_state, data)
      for _, k in ipairs(saved) do
        k = self.loaded[name][i]
      end
    end
  end

  -- keep walking the dependency graph to make sure all instances
  -- of this mod are reloaded
  if self.loaded then
    for i, filename in ipairs(self.loaded) do
      for i2, mod in ipairs(self.loaded[filename]) do
        mod:reload(name, data)
      end
    end
  end
end

function Base:get(key)
  return self.state[key]
end

function Base:set(key, value)
  if type(key) == 'table' and not value then
    self.state = key
  else
    self.state[key] = value
  end

  -- set up a closure to call this state key as an accessor
  self[key] = function(self)
    return self.state[key]
  end 
end

function Base:load_and_set(name)
  self:set(name, self:load(name))
end

function Base.static:builder()
  return function(loader, state)
    return self:new(loader, state) 
  end
end

function Base:not_defined(method_name, class_name)
  assert(false, string.format('`%s` must be defined by `%s` descendants.', method_name, class_name))
end

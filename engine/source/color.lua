Color = class('Color')

function Color:initialize(r, g, b, a)
  self.r = r
  self.g = g
  self.b = b
  self.a = a
end

function Color:raw()
  return {
    r = self.r, 
    g = self.g, 
    b = self.b, 
    a = self.a
  }
end

function Color:apply(r, g, b, a)
  if r then self.r = r; end
  if g then self.g = g; end
  if b then self.b = b; end
  if a then self.a = a; end
end

function Color:__tostring()
  return '(' .. self.r .. ', ' .. self.g .. ', ' .. self.b .. ', ' .. self.a .. ')'
end

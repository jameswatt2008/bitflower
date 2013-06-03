local util = {}

function util.split(str, sep)
  local sep, fields = sep or ":", {}
  local pattern = string.format("([^%s]+)", sep)
  str:gsub(pattern, function(c) fields[#fields+1] = c end)
  return fields
end

function util.path_if_absolute(path)
  local s,e = path:find('/')
  if s == 1 and e == 1 then
    return path
  else
    return nil
  end
end

function util.last(t)
  return t[#t]
end

function util.capitalize(str)
  return str:sub(1,1):upper() .. str:sub(2)
end

return util

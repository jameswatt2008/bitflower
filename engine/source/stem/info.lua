return function(stem, client) 
  local info = json.encode({
    name = bitflower.name,
    id   = bitflower.identifier
  })
  stem:send_string(client, 'INFO', info)
end

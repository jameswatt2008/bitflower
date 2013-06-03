return function(stem, client) 
  local icon_handle = io.open(bitflower.application_path .. '/../114.png', 'rb')
  local icon_data = icon_handle:read('*a')
  icon_handle:close()

  local sent, err = stem:send_bytes(client, 'ICON', icon_data)
end

return function(stem, client, data)
  stem:state_subscribers()[#stem:state_subscribers() + 1] = data
  stem:send_string(client, 'SSUB', 'subscribed')
end

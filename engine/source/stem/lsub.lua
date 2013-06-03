local util = require('util')

return function(stem, client)
  local ip = util.split(client:getpeername(), ':')[1]
  stem:log_subscribers()[#stem:log_subscribers() + 1] = ip
  stem:send_string(client, 'LSUB', 'subscribed')
end

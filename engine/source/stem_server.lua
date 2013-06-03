local inspect = require('inspect')
local json    = require('json')
local fmt     = string.format

local StemServer = class('StemServer', Base)

function StemServer:default()
  self:set('clients', {})
end

function StemServer:add_client(client)
  raw_log('Client connected!')
  table.insert(self:clients(), client)
end

function StemServer:remove_client(client)
  raw_log('Client disconnected!')
  for i, c in pairs(self:clients()) do
    if c == client then table.remove(self:clients(), i) end
  end
end

function StemServer:handle_message(client, message)
  raw_log(message)
end

return StemServer:builder()

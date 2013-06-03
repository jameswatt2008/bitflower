package.path  = package.path .. ';support/scripts/?.lua;support/libraries/?.lua'
package.cpath = 'support/libraries/c;' .. package.cpath

local fmt    = string.format
local colors = require('term_colors')

function print_color(msg)
  msg = msg:gsub('|r|',  tostring(colors.red))
  msg = msg:gsub('|g|',  tostring(colors.green))
  msg = msg:gsub('|w|',  tostring(colors.white))
  msg = msg:gsub('|b|',  tostring(colors.bright))
  msg = msg:gsub('|u|',  tostring(colors.underscore))
  msg = msg:gsub('|rb|', tostring(colors.red)   .. colors.bright)
  msg = msg:gsub('|gb|', tostring(colors.green) .. colors.bright)
  msg = msg:gsub('|wb|', tostring(colors.white) .. colors.bright)
  msg = msg:gsub('|/|',  tostring(colors.reset))
  print('\n' .. msg .. '\n')
end

local start_path = arg[1]
local command    = arg[2]

-- arg[3] and on are the actual command args
local i = 3
local command_args = {}
while i <= #arg do
  command_args[i - 2] = arg[i]
  i = i + 1
end

if not command then
  require('commands.help'):run()
else
  local status, result = pcall(require, fmt('commands.%s', command))

  if status then
    local start_path = arg[1]
    result:run(start_path, command_args)
  else
    print_color(fmt([[
    |r|Unknown command `%s`.|/| Type |w|`./bf help`|/| for usage information.]], command))
  end
end

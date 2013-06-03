local fmt = string.format

local VersionCommand = {}

function VersionCommand:run(args)
  local git_command = 'git rev-parse --short HEAD'
  local hash        = io.popen(git_command)
  local version     = io.open('support/VERSION', 'r')

  local hash_str    = hash:read('*a'):gsub('\n', '')
  hash:close()

  local version_str = version:read('*a'):gsub('\n', '')
  version:close()

  print_color(fmt([[
  |w|Version %s|/|, |w|Build %s|/|]], version_str, hash_str))
end

function VersionCommand:help()
  print_color[[
  Prints the currently installed Bitflower version.

  Usage:
    bf version]]
end

return VersionCommand

local fmt = string.format

local HelpCommand = {}

function HelpCommand:run(start_path, args)
  if not args then
    self:print_general_help()
  else
    local command = args[1]
    local status, result = pcall(require, fmt('commands.%s', command))
    if status then
      result:help()
    else
      self:print_general_help()
    end
  end
end

function HelpCommand:print_general_help()
  print_color[[
  |w|bf|/| is a tool for creating, building, deploying, and live-coding Bitflower 
  apps and games. If this is your first time using |w|bf|/|, make sure you run
  |w|./bf bootstrap|/| from your local installion of Bitflower first.

  Usage:
    |w|bf <command> [arg1] [arg2] ... [argn]|/|

  Commands:
    |w|bootstrap|/|   symlinks /usr/local/bin/bf to your local installation of bf
    |w|create|/|      generates a new project skeleton under apps/
    |w|build|/|       compiles and links an app for a given platform
    |w|deploy|/|      installs an app to the device of your choosing
    |w|stem|/|        connects to one or more running instances of a Bitflower app
    |w|help|/|        prints this output, or help for a command if one is specified
    |w|version|/|     prints the current version of Bitflower

  Use |w|`bf help <command>`|/| for more information about a command.]]
end

return HelpCommand

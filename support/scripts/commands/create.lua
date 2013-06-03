local fmt      = string.format
local util     = require('util')
local lustache = require('lustache')

local CreateCommand = {}

function CreateCommand:run(start_path, args)
  local project_path = util.path_if_absolute(args[1]) or fmt('%s/%s', start_path, args[1])
  local project_name = args[2] or util.last(util.split(project_path, '/'))

    os.execute('mkdir -p ' .. project_path)
    os.execute('cp -r support/templates/mobile/* ' .. project_path)

    local build_template = io.open(fmt('%s/build.template', project_path), 'r')
    local body           = build_template:read('*a')
    local result         = lustache:render(body, { name = project_name })
    build_template:close()

    local build_file = io.open(fmt('%s/build.lua', project_path), 'w')
    build_file:write(result)
    build_file:close()

    os.execute(fmt('rm %s/build.template', project_path))
    print_color(fmt([[
    |g|Successfully|/| created new project |w|%s|/| at |w|%s|/|.]], project_name, project_path))
end

function CreateCommand:help()
  print_color[[
  Creates a Bitflower project skeleton at the path of your choosing.

  Usage:
    bf create <path_to_new_app> [name]
  
  Examples:
    |w|bf create ~/games/tron|/|
      create a project at ~/games/tron and set the app name to 'tron' (which
      you can change afterward in ~/games/tron/build.lua).

    |w|bf create tron|/|
      create a project at ./tron and set the app name to 'tron' (which
      you can change afterward in ~/games/tron/build.lua).

    |w|bf create ~/games/tron Tron|/|
      create a project at ~/games/tron and set the app name to 'Tron'.
    
    |w|bf create tron Tron|/|
      create a project at ./tron and set the app name to 'Tron'.]]
end

return CreateCommand

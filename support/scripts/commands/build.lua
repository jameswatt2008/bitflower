local fmt  = string.format
local util = require('util')

local BuildCommand = {}

function BuildCommand:run(start_path, args)
  self.project_path = start_path

  -- grab the build.lua file
  local build_file = loadfile(start_path .. '/build.lua')
  if not build_file then
    self:print_invalid_directory()
    return
  else
    build_file = build_file()
  end

  -- set-up the default flags
  self.configuration = 'debug'
  self.platform      = 'ios'
  self.deploy        = false
  self.clean         = false

  -- figure out what kind build we're doing
  self:parse_args(args)

  -- do the native build first
  local build_script  = require('commands.build_scripts.' .. self.platform)
  local native_result = build_script:go({
    name         = build_file.name,
    path         = self.project_path,
    orientations = build_file.orientations,
    devices      = build_file.devices,
    version      = build_file.version,
    build_type   = self.configuration,
    ios          = build_file.ios,
    clean        = self.clean,
    shallow      = self.shallow
  })

  if native_result then
    print_color(fmt([[
  |g|You've got a freshly built Bitflower app at:
  %s|/|]], native_result))

    if self.deploy then
      build_script:deploy()
    end
  else
    self:print_bad_build()
  end
end

function BuildCommand:help()
  print_color[[
  Builds and optionally deploys a Bitflower app. By default, |w|`build`|/| will use 
  the |w|-debug|/| and |w|-ios|/| flags. |w|`build`|/| |u|must|/| be executed in a valid Bitflower 
  project directory.

  Usage:
    bf build [-debug/-release] [-ios/-android] [-shallow] [-deploy]
  
  Examples:
    |w|bf build|/|
      build an iOS debug version and put it in ./build/debug/ios.
    
    |w|bf build -shallow|/|
      skip the native build, and simply replace the Lua logic embedded in the
      already-built native artifact. Note that you |u|must|/| have already built
      a native artificat for this to work.

    |w|bf build -deploy|/|
      build an iOS debug version, put it in ./build/debug/ios, and deploy to the
      currently connected device.

    |w|bf build -release -android|/|
      build an android release version and put it in ./build/release/android.

    |w|bf build -android -deploy|/|
      build an android debug version, put it in ./build/debug/android, and deploy 
      to the currently connected device.]]
end

function BuildCommand:parse_args(args)
  for _,arg in ipairs(args) do
    self:set_flag(arg)
  end
end

function BuildCommand:set_flag(arg)
  if arg == '-debug' then
    self.configuration = 'debug'
  elseif arg == '-release' then
    self.configuration = 'release'
  elseif arg == '-ios' then
    self.platform = 'ios'
  elseif arg == '-android' then
    self.platform = 'android'
  elseif arg == '-deploy' then
    self.deploy = true
  elseif arg == '-clean' then
    self.clean = true
  elseif arg == '-shallow' then
    self.shallow = true
  end
end

function BuildCommand:print_invalid_directory()
  print_color[[
  |r|This is not a valid Bitflower project directory!|/|]]
end

function BuildCommand:print_bad_build()
  print_color[[
  |r|The build failed! Please see the errors above for an explanation.|/|]]
end

return BuildCommand

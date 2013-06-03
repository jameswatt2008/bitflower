local fmt = string.format

local DeployCommand = {}

function DeployCommand:run(start_path, args)

  local build_file = loadfile(start_path .. '/build.lua')
  if not build_file then
    self:print_invalid_directory()
    return
  else
    build_file = build_file()
  end

  self.name       = build_file.name
  self.platform   = 'ios'
  self.build_path = fmt('%s/build/ios/debug', start_path)

  self:parse_args(args)
  self[self.platform](self)
end

function DeployCommand:help()
  print_color[[
  Deploys a built bitflower app to a connected device. Note that |w|`deploy`|/| can
  only be used for debug builds, and will try an iOS deployment by default. |w|`deploy`|/| 
  only works in a valid Bitflower project directory.

  Usage:
    bf deploy [-android]
  
  Examples:
    |w|bf deploy|/|
      will install a debug build to a connected iOS device.

    |w|bf deploy -android|/|
      will install a debug build to a connected Android device.]]
end

function DeployCommand:parse_args(args)
  for _,arg in ipairs(args) do
    self:set_flag(arg)
  end
end

function DeployCommand:print_invalid_directory()
  print_color[[
  |r|This is not a valid Bitflower project directory!|/|]]
end

function DeployCommand:set_flag(arg)
  if arg == '-android' then
    self.platform = 'android'
  end
end

function DeployCommand:ios()
  print[[

  Trying to install on a USB-connected iOS device...]]
  
  local bundle = fmt('%s/%s.app', self.build_path, self.name)
  local deploy_cmd = fmt('support/binaries/fruitstrap -t 1 -b %s > /dev/null', bundle)
  if os.execute(deploy_cmd) == 0 then
    print_color(fmt([[
  |g|%s was successfully installed on your device!|/|]], self.name))
  else
    print_color(fmt([[
  |r|%s failed to be installed on your device!|/| 
  
  Make sure the device is properly connected and that it has your development provisioning 
  profile loaded.]], self.name))
  end
end

return DeployCommand

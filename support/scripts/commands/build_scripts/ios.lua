local fmt     = string.format
local inspect = require('inspect')
local util    = require('util')

local IOSBuildScript = {}

function IOSBuildScript:go(info)
  self.info = info

  local bitflower_path = os.getenv('PWD')
  local build_path = fmt('%s/build/ios/%s', info.path, info.build_type)
  os.execute('mkdir -p ' .. build_path)

  self.build_path = build_path

  -- short-circuit the build process if they want to just replace the lua files
  if info.shallow then
    print[[

  `-shallow` flag detected: skipping native build.]]

    self:copy_resources(bitflower_path, build_path, info)
    local result = self:resign_app(build_path, info)

    if result == 0 then
      return build_path .. '/' .. info.name .. '.app'
    else
      return false
    end
  end

  local build_string
  if info.clean then
    build_string = fmt('%s/support/xctool/xctool.sh -workspace %s/native/ios/xcode/xcode.xcworkspace -scheme xcode -configuration %s -sdk iphoneos clean build BITFLOWER_APP_NAME=%s PRODUCT_NAME=%s BITFLOWER_BUNDLE_ID=%s BITFLOWER_VERSION=%s CONFIGURATION_BUILD_DIR=%s',
      bitflower_path, bitflower_path, util.capitalize(info.build_type), info.name, info.name, info.ios.bundle_id, info.version, build_path)
  else
    build_string = fmt('%s/support/xctool/xctool.sh -workspace %s/native/ios/xcode/xcode.xcworkspace -scheme xcode -configuration %s -sdk iphoneos build BITFLOWER_APP_NAME=%s PRODUCT_NAME=%s BITFLOWER_BUNDLE_ID=%s BITFLOWER_VERSION=%s CONFIGURATION_BUILD_DIR=%s',
      bitflower_path, bitflower_path, util.capitalize(info.build_type), info.name, info.name, info.ios.bundle_id, info.version, build_path)
  end

  local build_result = os.execute(build_string)
  if build_result ~= 0 then
    return false
  else
    -- copy over resources
    self:copy_resources(bitflower_path, build_path, info)
    
    -- re-sign the app
    local result = self:resign_app(build_path, info)

    if result == 0 then
      return build_path .. '/' .. info.name .. '.app'
    else
      return false
    end
  end
end

function IOSBuildScript:copy_resources(bitflower_path, build_path, info)
  os.execute(fmt('mkdir -p %s/%s.app/engine', build_path, info.name))
  os.execute(fmt('mkdir -p %s/%s.app/application/libraries', build_path, info.name))
  os.execute(fmt('mkdir -p %s/%s.app/application/source', build_path, info.name))
  os.execute(fmt('mkdir -p %s/%s.app/application/scenes', build_path, info.name))
  os.execute(fmt('mkdir -p %s/%s.app/assets', build_path, info.name))
  
  os.execute(fmt('cp -r %s/engine %s/%s.app', bitflower_path, build_path, info.name))
  
  os.execute(fmt('cp -r %s/libraries %s/%s.app/application', info.path, build_path, info.name))
  os.execute(fmt('cp -r %s/source %s/%s.app/application', info.path, build_path, info.name))
  os.execute(fmt('cp -r %s/scenes %s/%s.app/application', info.path, build_path, info.name))
  
  os.execute(fmt('cp -r %s/assets %s/%s.app', info.path, build_path, info.name))
  os.execute(fmt('cp %s/icons/* %s/%s.app', info.path, build_path, info.name))
  os.execute(fmt('cp %s/splash/* %s/%s.app', info.path, build_path, info.name))
end

function IOSBuildScript:resign_app(build_path, info)
  if info.build_type == 'debug' then
    return os.execute(fmt('codesign --verbose=0 -f -s "iPhone Developer: " %s/%s.app > /dev/null', build_path, info.name))
  else
    return os.execute(fmt('codesign --verbose=0 -f -s "iPhone Distribution: " %s/%s.app > /dev/null', build_path, info.name))
  end
end

function IOSBuildScript:deploy()
  print[[
  `-deploy` flag detected: trying to install on a USB-connected iOS device...]]
  local bundle = fmt('%s/%s.app', self.build_path, self.info.name)
  local deploy_cmd = fmt('support/binaries/fruitstrap -t 1 -b %s > /dev/null', bundle)
  if os.execute(deploy_cmd) == 0 then
    print_color(fmt([[
  |g|%s was successfully installed on your device!|/|]], self.info.name))
  else
    print_color(fmt([[
  |r|%s failed to be installed on your device!|/| Make sure you've properly connected
  it and that it has your development provisioning profile loaded. You can try again
  with |w|`bf deploy`|/|]], self.info.name))
  end
end

return IOSBuildScript

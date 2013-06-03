-- Simply creates a symlink at /usr/local/bin/bitflower so developers
-- can omit the './' from the front of their commands. A small, but useful
-- enhancement.

local fmt = string.format

local BootstrapCommand = {}

function BootstrapCommand:run(args)
  local bitflower_path = os.getenv('PWD') .. '/bf'
  if os.execute(fmt('ln -sf %s /usr/local/bin/bf', bitflower_path)) == 0 then
    print_color[[
    Ok, |w|`/usr/local/bin/bf`|/| now points to |w|`./bf`|/|. Provided that /usr/local/bin is in 
    your $PATH, you can now just type `bf` to use bitflower.]]
  end
end

function BootstrapCommand:help()
  print_color[[
  Creates a symlink so that you don't have to type the full path to the bf command.
  You |u|must|/| run this command from your local installation of bitflower.]]
end

return BootstrapCommand

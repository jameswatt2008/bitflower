local StemCommand = {}

function StemCommand:run(start_path, args)
  os.execute('open support/stem/Stem.app')
end

function StemCommand:help()
  print_color[[
  Opens the Stem app, and connects you to one or more running Bitflower instances.

  Usage:
    bf stem]]
end

return StemCommand

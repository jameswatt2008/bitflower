var gui = require('nw.gui');
var win = gui.Window.get();

var fs = require('fs');

var pathToWatch = process.env.PWD + '/support/stem/Stem.app/Contents/Resources/app.nw';

fs.watch(pathToWatch,                 {}, function(event, filename) { win.reload(); });
fs.watch(pathToWatch + '/js',         {}, function(event, filename) { win.reload(); });
fs.watch(pathToWatch + '/js/lib',     {}, function(event, filename) { win.reload(); });
fs.watch(pathToWatch + '/js/src',     {}, function(event, filename) { win.reload(); });
fs.watch(pathToWatch + '/styles/css', {}, function(event, filename) { win.reload(); });
fs.watch(pathToWatch + '/templates',  {}, function(event, filename) { win.reload(); });

// sys = require('sys')
// exec = require('child_process').exec
// exec "ping -t 1 224.0.0.1 | grep -Eo '[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}'", (error, stdout, stderr) ->
//   ips = _.reject(_.uniq(stdout.split('\n')), ((ip) -> return ip == '224.0.0.1' || ip == ''))

// net   = require('net')
// dgram = require('dgram')

// {EventEmitter} = require('events')

// # the Stem protocol looks like the following:
// # commandsizedata
// # where `command` is 4 bytes, `size` is 16 bytes, and data is `size` bytes 

// class @StemConnection extends EventEmitter
//   constructor: (ip) ->
//     @rpcCBMap = {}

//     @rpcSocket = net.connect({port: 31771, host: ip})
//     @rpcSocket.on 'connect', =>
//       @emit('valid')
//       @send('LSUB', null)
//       @send('SSUB', null)

//     @rpcSocket.on 'error', =>
//       @emit('invalid')

//     @rpcSocket.on 'end', =>
//       @emit('closed')

//     @logSocket = dgram.createSocket('udp4');
//     @logSocket.bind(31772)

//     @stateSocket = dgram.createSocket('udp4');
//     @stateSocket.bind(31773)

//     @listen()

//   close: =>
//     @rpcSocket.destroy()
//     @logSocket.close()
//     @stateSocket.close()

//   send: (command, data, cb) =>
//     message
//     if data == null
//       size = (1e16 + 0 + '').substr(1)
//       message = "#{command}#{size}\n"
//     else
//       size = (1e16 + data.length + '').substr(1)
//       message = "#{command}#{size}#{data}\n"
    
//     @rpcCBMap[command] = cb if cb
//     @rpcSocket.write message

//   listen: =>
//     @buf = new Buffer(0)
//     @size = 0

//     @rpcSocket.on 'data', (incoming) =>
//       if @buf.length == 0
//         @command = incoming.slice(0, 4)
//         @size    = parseInt(incoming.slice(4, 20), 10)
//         data     = incoming.slice(20)
//         @buf     = Buffer.concat([@buf, data])

//         # did it all fit in one frame?
//         if @buf.length == @size + 1
//           @fireCallback()

//       else
//         @buf = Buffer.concat([@buf, incoming])

//         # got everything?
//         if @buf.length == @size + 1
//           @fireCallback()

//     @logSocket.on 'message', (msg, rinfo) =>
//       @emit('log_item', msg)

//     @stateSocket.on 'message', (msg, rinfo) =>
//       @emit('state_item', msg)

//   fireCallback: =>
//     newBuf = new Buffer(@buf.length)
//     @buf.copy(newBuf)
//     @rpcCBMap[@command](newBuf) if @rpcCBMap[@command]

//     @buf = new Buffer(0)
//     @command = undefined
//     @size = 0


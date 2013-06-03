-- Although log() is the best way to record output to various remote consoles (which
-- should _always_ be used) we still, on occasion, want access to the native stdout 
-- device. This calls into the *bitflower.log* cfunction, which is just a wrapper 
-- for the platform's native log call (e.g., NSLog on iOS).
function raw_log(msg)
  bitflower.log(msg)
end

-- Queues the log message for delivery to any listening remote consoles.
function log(msg)
  engine:stem_server():log('info', msg)
end

function log_warning(msg)
  engine:stem_server():log('warning', msg)
end

function log_error(msg)
  engine:stem_server():log('error', msg)
end

function log_critical(msg)
  engine:stem_server():log('critical error', msg)
end

function add_stem_client(client)
  engine:stem_server():add_client(client)
end

function remove_stem_client(client)
  engine:stem_server():remove_client(client)
end

function handle_stem_message(client, message)
  engine:stem_server():handle_message(client, message)
end

-- The native wrapper will call this *app_config.tick_rate* times a second. We
-- wrap it in a pcall just in case there is an error in the code. Also note that
-- we cache the previous error and compare it to this one--if it is the same,
-- we don't display it on every frame, but rather every two seconds (so as not to
-- annoyingly flood the logs on a per frame error).
function tick(dt)
  local function protected_tick(dt)
    engine:tick(dt)
  end
  local res, err = pcall(protected_tick, dt)
  if err then
    if bitflower.tick_error and bitflower.tick_error == err then
      -- rate-limit the error logging to every two seconds
      if engine:elapsed_ticks() % (engine:tick_rate() * 2) == 0 then
        log_error('(throttled) ' .. err)
      end
    else
      bitflower.tick_error = err
      log_error(err)
    end
  -- no error, so clear the cached error if any
  elseif bitflower.tick_error then
    bitflower.tick_error = nil
  end
end

-- function __FILE__() return debug.getinfo(2, 'S').source end
-- function __LINE__() return debug.getinfo(2, 'l').currentline end

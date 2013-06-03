-- we always check whether the module exists in the Library path first,
-- because modules there will be the most up-to-date versions
-- package.path = package.path .. ';' .. bitflower.library_path .. '/engine/source/?.lua'
-- package.path = package.path .. ';' .. bitflower.library_path .. '/engine/libraries/?.lua'

-- package.path = package.path .. ';' .. bitflower.library_path .. '/application/source/?.lua'
-- package.path = package.path .. ';' .. bitflower.library_path .. '/application/scenes/?.lua'
-- package.path = package.path .. ';' .. bitflower.library_path .. '/application/libraries/?.lua'

-- then we check our built-in code
package.path = package.path .. ';' .. bitflower.engine_path      .. '/source/?.lua'
package.path = package.path .. ';' .. bitflower.engine_path      .. '/libraries/?.lua'

package.path = package.path .. ';' .. bitflower.application_path .. '/source/?.lua'
package.path = package.path .. ';' .. bitflower.application_path .. '/scenes/?.lua'
package.path = package.path .. ';' .. bitflower.application_path .. '/libraries/?.lua'

-- give them raw apis in case they want them
bitflower.gl = require('gl')

require('global_functions')

require('middleclass')
require('base')

local app_config = require('app_config')

-- the container object is the root node of the load dependency tree
bitflower.container = require('container')(nil)

-- load the engine module and set bitflower.container.state.engine to it
bitflower.container:load_and_set('engine')

-- provide a handy global pointer to the engine instance
engine = bitflower.container:engine()

-- tell the native wrapper its tick rate
engine:set_tick_rate(app_config.tick_rate)

-- load up and activate the specified start scene
engine:change_scene(app_config.start_scene)

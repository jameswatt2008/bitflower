#import "WebSocket.h"

#import <luajit/luajit.h>
#import <luajit/lualib.h>
#import <luajit/lauxlib.h>

@interface StemDelegate : NSObject <WebSocketDelegate> {
  lua_State* L;
}

- (id)initWithLuaState:(lua_State*)luaState;

@end

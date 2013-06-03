#import "StemDelegate.h"

@implementation StemDelegate

- (id)initWithLuaState:(lua_State*)luaState {
  self = [super init];
  if (self) {
    L = luaState;
  }
  return self;
}


- (void)webSocketDidOpen:(WebSocket *)ws {
  lua_getglobal(L, "add_stem_client");
  lua_pushlightuserdata(L, (__bridge void*)ws);
  lua_call(L, 1, 0);
}

- (void)webSocket:(WebSocket *)ws didReceiveMessage:(NSString *)msg {
  lua_getglobal(L, "handle_stem_message");
  lua_pushlightuserdata(L, (__bridge void*)ws);
  lua_pushstring(L, [msg UTF8String]);
  lua_call(L, 2, 0);
}

- (void)webSocketDidClose:(WebSocket *)ws {
  lua_getglobal(L, "remove_stem_client");
  lua_pushlightuserdata(L, (__bridge void*)ws);
  lua_call(L, 1, 0);
}

@end

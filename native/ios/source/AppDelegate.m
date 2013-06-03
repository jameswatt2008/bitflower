//
//  AppDelegate.m
//  xcode
//
//  Created by Nicholas DeMonner on 5/2/13.
//  Copyright (c) 2013 DeMonner Industries LLC. All rights reserved.
//

#import "AppDelegate.h"

#include <stdio.h>
#include <stdlib.h>

#import <mach/mach.h>
#import <mach/mach_time.h>

#import <luasocket/luasocket.h>
#import <luasocket/mime.h>

#import "DDLog.h"
#import "DDTTYLogger.h"
#import "DDASLLogger.h"

#import "HTTPServer.h"
#import "StemConnection.h"
#import "WebSocket.h"

static double tick_rate;

int lua_log(lua_State* L) {
  const char* msg = lua_tostring(L, 1);
  NSLog(@"Lua log: %s", msg);

  return 0;
}

int lua_stem_socket_send(lua_State* L) {
  WebSocket* socket = (__bridge WebSocket*)lua_touserdata(L, 1);
  const char* message = lua_tostring(L, 2);

  [socket sendMessage:[NSString stringWithUTF8String:message]];

  return 0;
}

int lua_set_tick_rate(lua_State* L) {
  tick_rate = lua_tonumber(L, 1);
  return 0;
}

@implementation AppDelegate

@synthesize glView = _glView;
@synthesize stemDelegate = _stemDelegate;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  [DDLog addLogger:[DDASLLogger sharedInstance]];
  [DDLog addLogger:[DDTTYLogger sharedInstance]];

  _stemServer = [[HTTPServer alloc] init];
  [_stemServer setConnectionClass:[StemConnection class]];
  [_stemServer setType:@"_stem._tcp."];

  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  
  // Override point for customization after application launch.
  CGRect screenBounds = [[UIScreen mainScreen] bounds];
  self.glView = [[OpenGLView alloc] initWithFrame:screenBounds];
  [self.window addSubview:_glView];

  self.window.backgroundColor = [UIColor whiteColor];
  [self.window makeKeyAndVisible];

  [self bootLua];
  _stemDelegate = [[StemDelegate alloc] initWithLuaState:_luaState];

  NSError *error;
  if(![_stemServer start:&error])
  {
    NSLog(@"Error starting HTTP Server: %@", error);
  }

  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  lua_close(_luaState);
  dispatch_source_cancel(_timer);
}

- (void)bootLua {
  // path to bitflower engine files
  NSString *engineDirectory = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"engine"];
  NSString *applicationDirectory = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"application"];
  // NSString *libraryDirectory = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"application"];

  _luaState = luaL_newstate();
  luaL_openlibs(_luaState);

  lua_getglobal(_luaState, "package");
  lua_getfield(_luaState, -1, "preload");
  
  /* put luaopen_socket_core in package.preload["socket.core"] */
  lua_pushcfunction(_luaState, luaopen_socket_core);
  lua_setfield(_luaState, -2, "socket.core");
  
  /* put luaopen_mime_core in package.preload["mime.core"] */
  lua_pushcfunction(_luaState, luaopen_mime_core);
  lua_setfield(_luaState, -2, "mime.core");
    
  lua_pop(_luaState, 2);  

  // set-up the global bitflower table
  lua_newtable(_luaState);

  lua_pushstring(_luaState, [engineDirectory UTF8String]);
  lua_setfield(_luaState, -2, "engine_path");

  NSString* bundleName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
  lua_pushstring(_luaState, [bundleName UTF8String]);
  lua_setfield(_luaState, -2, "name");

  lua_pushstring(_luaState, [applicationDirectory UTF8String]);
  lua_setfield(_luaState, -2, "application_path");

  lua_pushstring(_luaState, [[[NSBundle mainBundle] bundleIdentifier] UTF8String]);
  lua_setfield(_luaState, -2, "identifier");
  
  lua_pushcfunction(_luaState, &lua_log);
  lua_setfield(_luaState, -2, "log");

  lua_pushcfunction(_luaState, &lua_set_tick_rate);
  lua_setfield(_luaState, -2, "set_native_tick_rate");

  lua_pushcfunction(_luaState, &lua_stem_socket_send);
  lua_setfield(_luaState, -2, "stem_socket_send");

  lua_setglobal(_luaState, "bitflower");

  // load the boot script
  int status = luaL_loadfile(_luaState, [[engineDirectory stringByAppendingPathComponent:@"source/boot.lua"]
                                 UTF8String]);
  if (status) {
    NSLog(@"Boot failed: %s", lua_tostring(_luaState, -1));
    exit(1);
  }

  // run it, and set up all of the necessary scene hooks for the developer
  // app
  int result = lua_pcall(_luaState, 0, LUA_MULTRET, 0);
  if (result) {
    NSLog(@"Runtime error: %s", lua_tostring(_luaState, -1));
    exit(1);
  }

  // set up a periodic timer to call the game engine tick
  _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
    0, 0, dispatch_get_main_queue());

  float interval = 1.0 / tick_rate;
  __block uint64_t timePrevious = [self currentTimeInMilliseconds];

  lua_pop(_luaState, 1);

  if (_timer) {
    dispatch_source_set_timer(_timer, timePrevious, (uint64_t)(interval * NSEC_PER_SEC), 0);

    dispatch_source_set_event_handler(_timer, ^{
      uint64_t timeCurrent = [self currentTimeInMilliseconds];
      uint64_t dt = timeCurrent - timePrevious;
      timePrevious = timeCurrent;

      lua_getglobal(_luaState, "tick");
      lua_pushnumber(_luaState, dt);

      lua_call(_luaState, 1, 0);
    });
    dispatch_resume(_timer);
  }
  else {
    NSLog(@"Couldn't start dispatch timer.");
    exit(1);
  }
}

- (uint64_t)currentTimeInMilliseconds {
  // return current time in milliseconds
  static mach_timebase_info_data_t timebaseInfo;

  // first time, grab timebaseInfo
  if (timebaseInfo.denom == 0) {
    (void) mach_timebase_info(&timebaseInfo);
  }

  uint64_t currentNano = mach_absolute_time() * timebaseInfo.numer / timebaseInfo.denom;
  return currentNano / 1000000ull;
}

@end

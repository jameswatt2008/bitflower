//
//  AppDelegate.h
//  xcode
//
//  Created by Nicholas DeMonner on 5/2/13.
//  Copyright (c) 2013 DeMonner Industries LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <luajit/luajit.h>
#import <luajit/lualib.h>
#import <luajit/lauxlib.h>

#import <dispatch/dispatch.h>

#import "OpenGLView.h"

#import "StemDelegate.h"

@class HTTPServer;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
  OpenGLView* _glView;
  lua_State* _luaState;
  dispatch_source_t _timer;

  StemDelegate* _stemDelegate;

  HTTPServer* _stemServer;
}

@property (strong, nonatomic) UIWindow* window;
@property (nonatomic, retain) IBOutlet OpenGLView* glView;
@property StemDelegate* stemDelegate;

@end

int luaopen_pack(lua_State *L);

//
//  OpenGLView.m
//  xcode
//
//  Created by Nicholas DeMonner on 5/2/13.
//  Copyright (c) 2013 DeMonner Industries LLC. All rights reserved.
//

#import "OpenGLView.h"

#include <luajit/luajit.h>
#include <luajit/lualib.h>
#include <luajit/lauxlib.h>

@implementation OpenGLView

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self setupLayer];
    [self setupContext];
    [self setupRenderBuffer];
    [self setupFrameBuffer];
    [self setupDisplayLink];
  }
  return self;
}

+ (Class)layerClass {
  return [CAEAGLLayer class];
}

- (void)setupLayer {
  _eaglLayer = (CAEAGLLayer*) self.layer;
  _eaglLayer.opaque = YES;
}

- (void)setupContext {
  EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
  _context = [[EAGLContext alloc] initWithAPI:api];
  
  if (!_context) {
    NSLog(@"Failed to initialize OpenGLES 2.0 context");
    exit(1);
  }
  
  if (![EAGLContext setCurrentContext:_context]) {
    NSLog(@"Failed to set current OpenGL context");
    exit(1);
  }
}

- (void)setupRenderBuffer {
  glGenRenderbuffers(1, &_colorRenderBuffer);
  glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
  [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}

- (void)setupFrameBuffer {
  GLuint framebuffer;
  glGenFramebuffers(1, &framebuffer);
  glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
  glFramebufferRenderbuffer(GL_FRAMEBUFFER,
                            GL_COLOR_ATTACHMENT0,
                            GL_RENDERBUFFER,
                            _colorRenderBuffer);
}

- (void)setupDisplayLink {
  CADisplayLink* displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
  [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}


- (void)render:(CADisplayLink*)displayLink {
    // glClearColor(255.0, 0, 0, 1.0);
    // glClear(GL_COLOR_BUFFER_BIT);
  [_context presentRenderbuffer:GL_RENDERBUFFER];
}

@end

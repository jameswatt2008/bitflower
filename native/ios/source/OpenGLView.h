//
//  OpenGLView.h
//  Bitflower
//
//  Created by Nicholas DeMonner on 5/2/13.
//  Copyright (c) 2013 DeMonner Industries LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
 
@interface OpenGLView : UIView {
  CAEAGLLayer* _eaglLayer;
  EAGLContext* _context;
  GLuint _colorRenderBuffer;
}

- (void)render:(CADisplayLink*)displayLink;

@end

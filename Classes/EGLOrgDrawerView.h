//
//  EGLOrgDrawerView.h
//  Evo1
//
//  Created by Tim Hinderliter on 5/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "DrawOrganism.h"

@interface EGLOrgDrawerView : UIView {
@private    
    EAGLContext *context;
    
    // The pixel dimensions of the CAEAGLLayer
    GLint backingWidth;
    GLint backingHeight;
    
    // The OpenGL ES names for the framebuffer and renderbuffer used to render to this view
    GLuint defaultFramebuffer, colorRenderbuffer;
}
    
- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer;
- (int)drawOrganism:(DrawOrganism*)organism andClear:(BOOL)shouldClear withColor:(GLfloat[4])color;

@end

//
//  EGLOrgDrawerView.m
//  Evo1
//
//  Created by Tim Hinderliter on 5/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EGLOrgDrawerView.h"

@implementation EGLOrgDrawerView

// Create an OpenGL ES 1.1 context
- (id)init
{
    if ((self = [super init]))
    {
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        
        if (!context || ![EAGLContext setCurrentContext:context])
        {
            [self release];
            return nil;
        }
        
        // Create default framebuffer object. The backing will be allocated for the current layer in -resizeFromLayer
        glGenFramebuffersOES(1, &defaultFramebuffer);
        glGenRenderbuffersOES(1, &colorRenderbuffer);
        glBindFramebufferOES(GL_FRAMEBUFFER_OES, defaultFramebuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, colorRenderbuffer);
    }
    
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    
    return [self init];
}


- (void)clear {
    // This application only creates a single default framebuffer which is already bound at this point.
    // This call is redundant, but needed if dealing with multiple framebuffers.
    [EAGLContext setCurrentContext:context];
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, defaultFramebuffer);
    //glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
    glViewport(0, 0, backingWidth, backingHeight);
    
    // Clear, set color, set basic identity matrices.
    glClearColor(0.1f, 0.1f, 0.1f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    //glScalef(0.10f, 0.10f, 1.0f);
}

- (void) present {
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
}    

- (GLfloat)drawOrganism:(DrawOrganism*)organism withSelected:(BOOL)isSelected withState:(DrawState*)drawState
{
    // Draw it.
    if (isSelected) {
        glColor4f(0.1f, 0.3f, 0.3f, 0.5f);

        CGFloat width = drawState.translate.x, height = drawState.translate.y;
        GLfloat vertices[] = {
            -.2 + width, -.1 + height,
            -.2 + width, -.2 + height,
             .2 + width, -.2 + height,
             .2 + width, -.1 + height,
        };
        glVertexPointer(2, GL_FLOAT, 0, vertices);
        glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    }
    GLfloat resultNumDraws = [organism drawGLWithState:drawState];

    return resultNumDraws;
}

- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer
{	
    // Allocate color buffer backing based on the current layer size
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:layer];
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
    
    if (glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES)
    {
        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
    
    return YES;
}

- (void)dealloc
{
    // Tear down GL
    if (defaultFramebuffer)
    {
        glDeleteFramebuffersOES(1, &defaultFramebuffer);
        defaultFramebuffer = 0;
    }
    
    if (colorRenderbuffer)
    {
        glDeleteRenderbuffersOES(1, &colorRenderbuffer);
        colorRenderbuffer = 0;
    }
    
    // Tear down context
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
    
    [context release];
    context = nil;
    
    [super dealloc];
}

@end

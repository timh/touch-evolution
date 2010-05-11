//
//  DrawOrganism.h
//  Evo1
//
//  Created by Tim Hinderliter on 4/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <OpenGLES/ES1/gl.h>
#import "Organism.h"
#import "DrawState.h"

@interface DrawOrganism : Organism {
    GLfloat fitness;
}

@property(readonly, nonatomic) GLfloat fitness;

- (GLfloat) drawGL;
- (GLfloat) drawGLWithState:(DrawState*)drawState;

@end

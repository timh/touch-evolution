//
//  DrawState.h
//  Evo1
//
//  Created by Tim Hinderliter on 4/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


#import <OpenGLES/ES1/gl.h>

@interface DrawState : NSObject {
	CGPoint translate;
	CGPoint scale;
	GLfloat rotate;
    GLfloat color[4];
}

- (DrawState*) init;
- (CGPoint) transformedPoint:(CGPoint)point;

- (CGPoint) translate:(CGPoint)offset;
- (CGPoint) scale:(CGPoint)toScale;
- (GLfloat) rotate:(GLfloat)toRotate;

@property(readonly, nonatomic) CGPoint translate;
@property(readwrite, nonatomic) GLfloat* color;

@end


@interface MachineState : NSObject {
	NSMutableArray * stack;
    int numRegisters;
    GLfloat * registers;
}

@property(nonatomic, readonly) NSArray* stack;

- (MachineState*) init:(int)numRegisters;
- (GLfloat) getReg:(int)regIdx;
- (GLfloat) setReg:(int)regIdx withValue:(GLfloat)value;
- (GLfloat) push:(GLfloat)number;
- (GLfloat) pop;
- (GLfloat) peek:(int)index;
- (void) clone:(int)num;

@end



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
    GLfloat* color;
}

- (DrawState*) init;
- (CGPoint) transformedPoint:(CGPoint)point;

- (CGPoint) translate:(CGPoint)offset;
- (CGPoint) scale:(CGPoint)toScale;
- (GLfloat) rotate:(GLfloat)toRotate;

@property(readonly, nonatomic) CGPoint translate;
@property(readwrite, nonatomic) GLfloat* color;

@end


typedef enum _CompareResult {
	EQUAL,
	LESSTHAN,
	GREATERTHAN,
} CompareResult;

@interface MachineState : NSObject {
	NSMutableArray * stack;
	CompareResult lastCompareResult; // machine carry bit
}

@property(nonatomic, readonly) NSArray* stack;
@property(nonatomic, readonly) CompareResult lastCompareResult;

- (MachineState*) init;
- (GLfloat) push:(GLfloat)number;
- (GLfloat) pop;
- (GLfloat) peek:(int)index;
- (void) clone:(int)num;
- (void) compareTopTwo;

@end



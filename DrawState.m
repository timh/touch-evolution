//
//  DrawState.m
//  Evo1
//
//  Created by Tim Hinderliter on 4/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DrawState.h"

@implementation DrawState

- (DrawState*) init {
	if (self = [super init]) {
		self->rotate = 0.0f;
		self->scale.x = self->scale.y = 1.0f;
		self->translate.x = self->translate.y = 0.0f;
        self->color[0] = self->color[1] = self->color[2] = self->color[3] = 1;
        
	}
	return self;
}

- (void) dealloc {
    [super dealloc];
}

@synthesize translate;
//@synthesize color;
- (GLfloat*) color {
    return self->color;
}

- (void) setColor:(GLfloat*)col {
    self->color[0] = col[0];
    self->color[1] = col[1];
    self->color[2] = col[2];
    self->color[3] = col[3];
}

- (CGPoint) transformedPoint:(CGPoint)point {
    CGPoint res;
    res.x = cosf(rotate) * scale.x * point.x;
    res.y = sinf(rotate) * scale.x * point.x;
    
    res.x += sinf(rotate) * scale.y * point.y;
    res.y += cosf(rotate) * scale.y * point.y;
    
    return res;
}

- (CGPoint) translate:(CGPoint)offset {
    CGPoint transformed = [self transformedPoint:offset];
    
	self->translate.x += transformed.x;
	self->translate.y += transformed.y;
	
	return self->translate;
}

- (CGPoint) scale:(CGPoint)toScale {
	self->scale.x *= toScale.x;
	self->scale.y *= toScale.y;
	return self->scale;
}

- (GLfloat) rotate:(GLfloat)toRotate {
	self->rotate += toRotate;
	return self->rotate;
}

- (NSString*) description {
    return [NSString stringWithFormat:@"%@ (scale %f, %f) (rotate %f) (translate %f,%f)",
            [self class],
            scale.x, scale.y,
            rotate,
            translate.x, translate.y];
}

@end

@implementation MachineState

@synthesize stack;

- (MachineState*) init:(int)inNumRegisters {
	if (self = [super init]) {
		self->stack = [[NSMutableArray new] retain];
        self->numRegisters = inNumRegisters;
        self->registers = (GLfloat*) calloc(sizeof(GLfloat) * numRegisters, 0);
	}
	return self;
}

- (void) dealloc {
	[self->stack dealloc];
    free(self->registers);
	[super dealloc];
}

- (GLfloat) getReg:(int)regIdx {
    //NSLog(@"get %d: %.2f\n", regIdx, registers[regIdx]);
    return registers[regIdx];
}

- (GLfloat) setReg:(int)regIdx withValue:(GLfloat)value {
    //NSLog(@"SET %d: %.2f = %.2f\n", regIdx, registers[regIdx], value);
    registers[regIdx] = value;
    return value;
}

- (GLfloat) push:(GLfloat)number {
	[stack addObject:[NSNumber numberWithFloat:number]];
	return number;
}

- (GLfloat) pop {
	GLfloat res = 0;
	if ([stack count] > 0) {
		res = [self peek:0];
		[stack removeLastObject];
	}
	return res;
}
	
- (GLfloat) peek:(int)index {
	GLfloat res = 0;
	if ([stack count] > index) {
		NSNumber * numLast = [stack objectAtIndex:([stack count] - index - 1)];
		res = [numLast floatValue];
	}
	return res;
}

- (void) clone:(int)num {
	for (int i = 0; i < num; i ++) {
		// each time we add another, 'num' means a more recent entry onto
		// the stack.
		[self push:[self peek:num]];
	}
}

- (NSString*) description {
    return [NSString stringWithFormat:@"%@ (stack size %d) :: ",
            [self class],
            [stack count], stack];
}

@end

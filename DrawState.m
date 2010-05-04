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
		
	}
	return self;
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

@synthesize translate;

- (CGPoint) scale:(CGPoint)toScale {
	self->scale.x *= toScale.x;
	self->scale.y *= toScale.y;
	return self->scale;
}

- (CGFloat) rotate:(CGFloat)toRotate {
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
@synthesize lastCompareResult;

- (MachineState*) init {
	if (self = [super init]) {
		self->stack = [[NSMutableArray new] retain];
		self->lastCompareResult = EQUAL;
	}
	return self;
}

- (void) dealloc {
	[self->stack dealloc];
	[super dealloc];
}

- (CGFloat) push:(CGFloat)number {
	[stack addObject:[NSNumber numberWithFloat:number]];
	return number;
}

- (CGFloat) pop {
	CGFloat res = 0;
	if ([stack count] > 0) {
		res = [self peek:0];
		[stack removeLastObject];
	}
	return res;
}
	
- (CGFloat) peek:(int)index {
	CGFloat res = 0;
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

- (void) compareTopTwo {
	CGFloat one = [self pop];
	CGFloat two = [self pop];
	
	if (one < two) {
		self->lastCompareResult = LESSTHAN;
	}
	else if (one > two) {
		self->lastCompareResult = GREATERTHAN;
	}
	else {
		self->lastCompareResult = EQUAL;
	}
}

- (NSString*) description {
    return [NSString stringWithFormat:@"%@ (stack size %d) :: ",
            [self class],
            [stack count], stack];
}

@end

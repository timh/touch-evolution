//
//  DrawState.h
//  Evo1
//
//  Created by Tim Hinderliter on 4/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


@interface DrawState : NSObject {
	CGPoint translate;
	CGPoint scale;
	CGFloat rotate;
}

- (DrawState*) init;
- (CGPoint) transformedPoint:(CGPoint)point;

- (CGPoint) translate:(CGPoint)offset;
- (CGPoint) scale:(CGPoint)toScale;
- (CGFloat) rotate:(CGFloat)toRotate;

@property(readonly, nonatomic) CGPoint translate;

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
- (CGFloat) push:(CGFloat)number;
- (CGFloat) pop;
- (CGFloat) peek:(int)index;
- (void) clone:(int)num;
- (void) compareTopTwo;

@end



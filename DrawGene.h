//
//  DrawGene.h
//  Evo1
//
//  Created by Tim Hinderliter on 4/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Gene.h"

typedef enum _DrawType {
	NUMBER = 0,                     // push 1
	CLONE1, CLONE2, CLONE3, CLONE4, // dup top 1, 2, 3, 4 (from current stack)
	POP,                            // pop 1
	
	ADD,       // pops 2, push 1
	SUBTRACT,  // pops 2, push 1
	MULTI,     // pops 2, push 1
	DIV,       // pops 2, push 1

	TRANSLATE, // pops 2 - x,y
	ROTATE,    // pops 1 - degrees
	RGBA,      // pops 4 - rgba
	
	SCALE,     // pops 2 - x, y
	
	CMP,       // compare - push 1: 0 <, .5 ==, > .99
	JMP_LTE,   // based on compare, 
	
	DRAW,      // a triangle
	
	_MIN = NUMBER,
	_MAX = DRAW,
} DrawType;
	
@interface DrawGene : NSObject<Gene> {
	DrawType type;
	CGFloat number;
}

@property(readonly, nonatomic) DrawType type;
@property(readonly, nonatomic) CGFloat	number;

+ (DrawGene*) randomGene;

- (NSString*) description;
- (NSString*) short_description;

@end

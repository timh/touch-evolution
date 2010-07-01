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
    
    LOAD_R1,   // load reg 0, pop 1
    LOAD_R2,   // load reg 1, pop 1
    LOAD_R3,   // load reg 2, pop 1
    LOAD_R4,   // load reg 3, pop 1
    
    STORE_R1,  // store from reg0, push
    STORE_R2,  // store from reg1, push
    STORE_R3,  // store from reg2, push
    STORE_R4,  // store from reg3, push
	
	ADD,       // r0, r1, result in r2
	SUBTRACT,  // r0, r1, result in r2
	MULTI,     // r0, r1, result in r2
	DIV,       // r0, r1, result in r2

	TRANSLATE, // r2, r3
	ROTATE,    // r3
	RGBA,      // r0, r1, r2, r3
	
	SCALE,     // r2, r3
	
	CMP,       // compare r0 & r1: set r3 = 0 for <, .5 for ==, > for .99
	JMP_LTE,   // r2 = [0,1) where to jump to, r3 for previous cmp results
	
	DRAW,      // a triangle
	
	_MIN = NUMBER,
	_MAX = DRAW,
    _SIZE = _MAX - _MIN + 1
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

//
//  DrawGene.m
//  Evo1
//
//  Created by Tim Hinderliter on 4/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DrawGene.h"

@implementation DrawGene

- (id<Gene>) mutate {
	//return self;
    return [DrawGene randomGene];
}

- (DrawGene*) init {
	if (self = [super init]) {
		self->type = NUMBER;
	}
	return self;
}

@synthesize number;
@synthesize type;


static double s_geneWeights[_SIZE] = {
    1, .5, .5, .5, .5, // NUMBER, CLONE1 - CLONE4
    .5,                // POP
    .7, .7, .7, .7,    // LOAD_1 - LOAD_4
    0, 0, 0, 0,        // STORE_1 - STORE_4 (not implemented, what would it do with no RAM?)
    .6, .6, .6, .6,    // +, -, *, /
    1.6, 1.6, 1.6, .9,    // translate, rotate, RGBA (color), scale
    .5, .5, .9,        // CMP, jump, draw
};
static double s_geneWeightsTotal = 0;

+ (DrawGene*) randomGene {
	DrawGene * result = [[DrawGene alloc] init];
    
#if 1 // weighted random type
    // Add up all the weights from the above array, then pick a random number
    // between 0 and that total weight. pick the "slot" that the random number
    // falls in, making higher numbers have bigger slots and therefore be 
    // more likely.
    // TODO: tim, 2010-6-28 - not thread safe!
    if (s_geneWeightsTotal == 0) {
        for (int i = 0; i < _SIZE; i ++) {
            s_geneWeightsTotal += s_geneWeights[i];
        }
    }
    
    double r = ((CGFloat)random() / (CGFloat)RAND_MAX) * s_geneWeightsTotal;
    double totalSoFar = 0;
    for (int i = 0; i < _SIZE; i ++) {
        totalSoFar += s_geneWeights[i];
        if (r < totalSoFar) {
            result->type = i + _MIN;
            break;
        }
    }
#else // all types same chance
	result->type = random() % (_MAX + 1);
#endif

    if (result->type == NUMBER || (result->type >= LOAD_R1 && result->type <= LOAD_R4)) {
        result->number = (CGFloat)random() / (CGFloat)RAND_MAX;
    }
	
	return result;
}


- (NSString*) description {
	NSString * result = nil;
	
	if (type >= _MIN && type <= _MAX) {
		static NSString * descriptions[] = {
			@"number", @"clone1", @"clone2", @"clone3", @"clone4",
			@"pop", 
            @"load_r1", @"load_r2", @"load_r3", @"load_r4", 
            @"store_r1", @"store_r2", @"store_r3", @"store_r4", 
            @"add", @"subtract", @"multi", @"div",
			@"translate", @"rotate", @"rgba", @"scale",
			@"cmp", @"jmpf", @"draw",
		};
		
		result = descriptions[type];
	}
	
	return result;
}

- (NSString*) short_description {
	NSString * result = nil;
	
	if (type >= _MIN && type <= _MAX) {
		static NSString * short_descriptions[] = {
			@"##", @"C1", @"C2", @"C3", @"C4",
			@" <", 
            @"L1", @"L2", @"L3", @"L4", 
            @"S1", @"S2", @"S3", @"S4", 
            @"+", @"-", @"*", @"/",
			@"T", @"R", @"C", @"S",
			@"=", @"j", @"D"
		};
		
		result = short_descriptions[type];
	}
	
	return result;
}

@end

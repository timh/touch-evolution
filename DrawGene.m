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

+ (DrawGene*) randomGene {
	DrawGene * result = [[DrawGene alloc] init];
	result->type = random() % (_MAX + 1);
    if (result->type == NUMBER) {
        result->number = (CGFloat)random() / (CGFloat)RAND_MAX;
    }
	
	return result;
}


- (NSString*) description {
	NSString * result = nil;
	
	if (type >= _MIN && type <= _MAX) {
		static NSString * descriptions[] = {
			@"number", @"clone1", @"clone2", @"clone3", @"clone4",
			@"pop", @"add", @"subtract", @"multi", @"div",
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
			@"#", @"1", @"2", @"3", @"4",
			@"<", @"+", @"-", @"*", @"/",
			@"T", @"R", @"C", @"S",
			@"=", @"j", @"D"
		};
		
		result = short_descriptions[type];
	}
	
	return result;
}

@end

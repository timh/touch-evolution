//
//  Organism.m
//  Evo1
//
//  Created by Tim Hinderliter on 4/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Organism.h"
#import "Gene.h"


@implementation Organism

- (id) initEmpty {
	if (self = [super init]) {
		genes = [[NSMutableArray arrayWithCapacity:10] retain];
	}
	return self;
}

- (void) dealloc {
	[genes release];
	[super dealloc];
}

@synthesize genes;

- (void) addGene:(id<Gene>)gene {
	[genes addObject:gene];
}

- (Organism*) mate:(Organism*)otherOrg andMutate:(BOOL)doMutate withWorld:(WorldParams*)world {
	Organism* result = [self cloneEmptyOrganism];
	
	// what to do if the orgs are different length, in general?
	int min = ([otherOrg->genes count] < [self->genes count]) ? [otherOrg->genes count] : [self->genes count];
    int mateLength;
    for (int i = 0; i < min; i += mateLength) {
        Organism* orgPicked;
        
        if ([world mateLengthPercentage] > 0) {
            // if mate length percentage is set at all, we will potentially 
            // mate many genes at one time, in a string. we will go from 1 to
            // the organism length times mateLengthPercentage.
            CGFloat r = (CGFloat)random()/(CGFloat)RAND_MAX;
            
            mateLength = min * r * [world mateLengthPercentage];
            if (mateLength < 1) {
                mateLength = 1;
            }
        }
        else {
            mateLength = 1;
        }
        
        if (random() % 2 == 0) {
            orgPicked = self;
        }
        else {
            orgPicked = otherOrg;
        }
        
        for (int inner = i; inner < i + mateLength && inner < min; inner ++) {
            id<Gene> genePicked = (orgPicked == self) ? [genes objectAtIndex:inner] : [otherOrg->genes objectAtIndex:inner];
            
            // mutate
            if (doMutate) {
                CGFloat r = (CGFloat)random()/(CGFloat)RAND_MAX;
                if (r < world.mutationRate) {
                    genePicked = [genePicked mutate];
                }
            }
                
            [result addGene:genePicked];
        }
    }
    
	return result;
}

// Not an interesting implemenation..
- (Organism*) cloneEmptyOrganism {
	return [[[self class] alloc] initEmpty];
}

- (NSString *) description {
	//return [NSString stringWithFormat:@"org - %@ -", genes];
	NSMutableString * res = [NSMutableString new];

	for (id<Gene> gene in genes) {
		if ([res length] > 0) {
			[res appendString:@", "];
		}
		[res appendString:[gene description]];
	}
	return res;
}

- (NSString *) short_description {
	NSMutableString * res = [NSMutableString new];
	for (id<Gene> gene in genes) {
		NSString *gene_desc = nil;

		if ([gene respondsToSelector:@selector(short_description)]) {
			gene_desc = [gene short_description];
		}
		else {
			gene_desc = [NSString stringWithFormat:@"%@ ", [gene description]];
		}
		
		[res appendString:gene_desc];
	}
	return res;
}


@end

//
//  Organism.h
//  Evo1
//
//  Created by Tim Hinderliter on 4/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Gene.h"
#import "WorldParams.h"

@interface Organism : NSObject {
	NSMutableArray * genes;
}

@property(nonatomic, readonly) NSMutableArray* genes;

- (id) initEmpty;
- (void) dealloc;

- (Organism*) mate:(Organism*)otherOrg andMutate:(BOOL)doMutate withWorld:(WorldParams*)world;
- (void) addGene:(id<Gene>)gene;
- (Organism*) cloneEmptyOrganism;
- (NSString*) short_description;

@end

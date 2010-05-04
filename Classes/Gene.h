//
//  gene.h
//  Evo1
//
//  Created by Tim Hinderliter on 4/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


@protocol Gene
- (id<Gene>)mutate;
- (NSString*)description;

@optional
- (NSString*)short_description;

@end

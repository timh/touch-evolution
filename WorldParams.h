//
//  WorldParams.h
//  Evo1
//
//  Created by Tim Hinderliter on 4/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

@interface WorldParams : NSObject {
	CGFloat mutationRate;
	CGFloat mutInsertRate, mutDeleteRate, mutChangeRate;
}

@property(nonatomic, readwrite) CGFloat mutationRate;
@property(nonatomic, readwrite) CGFloat mutInsertRate;
@property(nonatomic, readwrite) CGFloat mutDeleteRate;
@property(nonatomic, readwrite) CGFloat mutChangeRate;

@end

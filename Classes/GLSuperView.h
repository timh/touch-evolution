//
//  GLSuperView.h
//  Evo1
//
//  Created by Tim Hinderliter on 5/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "EGLOrgDrawerView.h"
#import "Organism.h"
#import "DrawOrganism.h"
#import "WorldParams.h"


@interface GLSuperView : UIView {
@private
    BOOL animating;
    BOOL displayLinkSupported;
    NSInteger animationFrameInterval;
    
    // Use of the CADisplayLink class is the preferred method for controlling your animation timing.
    // CADisplayLink will link to the main display and fire every vsync when added to a given run-loop.
    // The NSTimer class is used only as fallback when running on a pre 3.1 device where CADisplayLink
    // isn't available.
    id displayLink;
    NSTimer *animationTimer;
	
    IBOutlet EGLOrgDrawerView *orgView;
	IBOutlet UILabel *textView;
	
	WorldParams * world;
	DrawOrganism * org1, * org2;
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;

- (void)startAnimation;
- (void)stopAnimation;
- (void)drawView:(id)sender;
- (void)setTextView:(UILabel*)label;

@end

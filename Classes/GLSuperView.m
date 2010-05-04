//
//  GLSuperView.m
//  Evo1
//
//  Created by Tim Hinderliter on 5/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GLSuperView.h"
#import "DrawGene.h"

@implementation GLSuperView

@synthesize animating;
@dynamic animationFrameInterval;

// You must implement this method
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

//The EAGL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder
{    
    if ((self = [super initWithCoder:coder]))
    {
        srandom(time(NULL));
        
        // Get the layer
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = TRUE;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        
        animating = FALSE;
        displayLinkSupported = FALSE;
        animationFrameInterval = 1;
        displayLink = nil;
        animationTimer = nil;
        
        // A system version of 3.1 or greater is required to use CADisplayLink. The NSTimer
        // class is used as fallback when it isn't available.
        NSString *reqSysVer = @"3.1";
        NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
        if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
            displayLinkSupported = TRUE;
		
        world = [[WorldParams alloc] init];
        world.mutationRate = .02f; // 2% mutation rate.
        
		// set up organism
		org1 = [[DrawOrganism alloc] initEmpty];
		org2 = [[DrawOrganism alloc] initEmpty];
		for (int i = 0; i < 300; i ++) {
			[org1 addGene:[DrawGene randomGene]];
			[org2 addGene:[DrawGene randomGene]];
		}
    }
    
    return self;
}

- (void)drawView:(id)sender
{
    DrawOrganism* child = [org1 mate:org2 andMutate:true withWorld:world];

    GLfloat red[] = { 1.0f, 0.0f, 0.0f, 1.0f };
    GLfloat green[] = { 0.0f, 1.0f, 0.0f, 1.0f };
    GLfloat yellow[] = { 1.0f, 1.0f, 0.0f, 1.0f };
    
    CGFloat org1Draws = [orgView drawOrganism:org1 andClear:TRUE withColor:red];
    CGFloat org2Draws = [orgView drawOrganism:org2 andClear:FALSE withColor:green];
    CGFloat childDraws = [orgView drawOrganism:child andClear:FALSE withColor:yellow];

    textView.text = [NSString stringWithFormat:@"--\norg1 = %.2f/%@\norg2 = %.2f/%@\nchild = %.2f/%@", 
                     org1Draws, [org1 short_description], 
                     org2Draws, [org2 short_description], 
                     childDraws, [child short_description]];
    
    DrawOrganism* killit = nil;
    
    float which = (float)random() / (float)RAND_MAX * (childDraws + org1Draws + org2Draws);
    if (which < childDraws) {
        float which2 = (float) random() / (float)RAND_MAX * (org1Draws + org2Draws);
        if (which2 < org1Draws) {
            killit = org2;
            org2 = child;
        }
        else {
            killit = org1;
            org1 = child;
        }
    }
    else if (which >= childDraws && which < org1Draws) {
        float which2 = (float) random() / (float)RAND_MAX * (childDraws + org2Draws);
        if (which2 < childDraws) {
            killit = org2;
            org2 = child;
        }
        else {
            killit = child;
        }
    }
    else {
        float which2 = (float) random() / (float)RAND_MAX * (childDraws + org1Draws);
        if (which2 < childDraws) {
            killit = org1;
            org1 = child;
        }
        else {
            killit = child;
        }
    }
    
    [killit release];
    
    usleep(100);
    [self setNeedsDisplay];
}

- (void)layoutSubviews
{
    [orgView resizeFromLayer:(CAEAGLLayer*)self.layer];

    [textView setNumberOfLines:100];
    textView.text = @"";
    textView.textAlignment = UITextAlignmentLeft;
    textView.font = [UIFont fontWithName:@"Arial" size:10];
    
    [self drawView:nil];
}

- (NSInteger)animationFrameInterval
{
    return animationFrameInterval;
}

- (void)setAnimationFrameInterval:(NSInteger)frameInterval
{
    // Frame interval defines how many display frames must pass between each time the
    // display link fires. The display link will only fire 30 times a second when the
    // frame internal is two on a display that refreshes 60 times a second. The default
    // frame interval setting of one will fire 60 times a second when the display refreshes
    // at 60 times a second. A frame interval setting of less than one results in undefined
    // behavior.
    if (frameInterval >= 1)
    {
        animationFrameInterval = frameInterval;
        
        if (animating)
        {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}

- (void)startAnimation
{
    if (!animating)
    {
        if (displayLinkSupported)
        {
            // CADisplayLink is API new to iPhone SDK 3.1. Compiling against earlier versions will result in a warning, but can be dismissed
            // if the system version runtime check for CADisplayLink exists in -initWithCoder:. The runtime check ensures this code will
            // not be called in system versions earlier than 3.1.
            
            displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(drawView:)];
            [displayLink setFrameInterval:animationFrameInterval];
            [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        }
        else
            animationTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)((1.0 / 60.0) * animationFrameInterval) target:self selector:@selector(drawView:) userInfo:nil repeats:TRUE];
        
        animating = TRUE;
    }
}

- (void)stopAnimation
{
    if (animating)
    {
        if (displayLinkSupported)
        {
            [displayLink invalidate];
            displayLink = nil;
        }
        else
        {
            [animationTimer invalidate];
            animationTimer = nil;
        }
        
        animating = FALSE;
    }
}

- (void)dealloc
{
    [super dealloc];
}

@end

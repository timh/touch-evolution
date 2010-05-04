//
//  EAGLView.m
//  Evo1
//
//  Created by Tim Hinderliter on 4/25/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "EAGLView.h"

#import "ES1Renderer.h"

#import "DrawOrganism.h"
#import "DrawGene.h"

@implementation EAGLView

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

        renderer = [[ES1Renderer alloc] init];

        if (!renderer)
        {
            [self release];
            return nil;
        }

        animating = FALSE;
        displayLinkSupported = FALSE;
        animationFrameInterval = 1;
        displayLink = nil;
        animationTimer = nil;
        textViewRunning = nil;

        // A system version of 3.1 or greater is required to use CADisplayLink. The NSTimer
        // class is used as fallback when it isn't available.
        NSString *reqSysVer = @"3.1";
        NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
        if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
            displayLinkSupported = TRUE;
		
		//self.autoresizesSubviews = TRUE;
		
        world = [[WorldParams alloc] init];
        world.mutationRate = .02f; // 2% mutation rate.
        
		// set up organism
		org1 = [[DrawOrganism alloc] initEmpty];
		org2 = [[DrawOrganism alloc] initEmpty];
		for (int i = 0; i < 300; i ++) {
			[org1 addGene:[DrawGene randomGene]];
			[org2 addGene:[DrawGene randomGene]];
		}
        
        org1Draws = org2Draws = 0;
    }

    return self;
}

- (void)setTextView:(UILabel*)label {
    // set up textview
    UIColor *bgColor = [[UIColor alloc] initWithWhite:1.0f alpha:0.0f];
    textViewRunning = label;
    textViewRunning.text = @"";
    textViewRunning.textAlignment = UITextAlignmentLeft;
    
    [textViewRunning setNumberOfLines:100];
    textViewRunning.backgroundColor = bgColor;
    textViewRunning.font = [UIFont fontWithName:@"Arial" size:12];
}

- (void)drawView:(id)sender
{
    DrawOrganism* child = [org1 mate:org2 andMutate:true withWorld:world];

    glClear(GL_COLOR_BUFFER_BIT);
    glColor4f(1.0, 0.0, 1.0, 1.0);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glEnableClientState(GL_VERTEX_ARRAY);
    
    glScalef(0.10f, 0.10f, 1.0f);

    glColor4f(1.0f, 0.0f, 0.0f, 1.0f); // red = child1
    org1Draws = [org1 drawGL];
    
    glColor4f(0.0f, 1.0f, 0.0f, 1.0f); // green = child2
    org2Draws = [org2 drawGL];
    
    glColor4f(1.0f, 1.0f, 0.0f, 1.0f); // yellow = offspring
    CGFloat childDraws = [child drawGL];

    textViewRunning.text = [NSString stringWithFormat:@"--\norg1 = %.2f/%@\norg2 = %.2f/%@\nchild = %.2f/%@", 
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
    
    //    if (textViewRunning != nil) {
//        textViewRunning.text = [NSString stringWithFormat:@"%@\n\ndraw res (org1) = %@",
//                                textViewRunning.text,
//                                org1res];
//        [textViewRunning setNeedsDisplay];
//    }
    
    [renderer render];
    [self setNeedsDisplay];
    //usleep(1000);
}

- (void)layoutSubviews
{
    [renderer resizeFromLayer:(CAEAGLLayer*)self.layer];
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
    [renderer release];

    [super dealloc];
}

@end

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

#define ORGSX 4
#define ORGSY 4
#define NUM_ORGS ORGSX*ORGSY
#define STATUS_HEIGHT_PERCENTAGE .15

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
        
        status = [NSMutableString new];
        
        // A system version of 3.1 or greater is required to use CADisplayLink. The NSTimer
        // class is used as fallback when it isn't available.
        NSString *reqSysVer = @"3.1";
        NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
        if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
            displayLinkSupported = TRUE;
		
        world = [[WorldParams alloc] init];
        world.mutationRate = .02f; // 2% mutation rate.
        world.mateLengthPercentage = 1.0f; // 100% of org length is maximum mate size

        orgs = [NSMutableArray new];
        orgSelected = (BOOL*) malloc(sizeof(BOOL) * NUM_ORGS);
        
        for (int i = 0; i < NUM_ORGS; i ++) {
            DrawOrganism* newOrg = [self newRandomOrg];

            [orgs addObject:newOrg];
            [newOrg release];
            
            orgSelected[i] = FALSE;
		}
        
    }
    
    return self;
}

- (DrawOrganism*) newRandomOrg
{
    DrawOrganism* newOrg = [[DrawOrganism alloc] initEmpty];
    
    for (int gene = 0; gene < 500; gene ++) {
        DrawGene* newGene = [DrawGene randomGene];
        [newOrg addGene:newGene];
        [newGene release];
    }
    
    return newOrg;
}


-(void) dealloc {
    [orgs release];
    [status release];
    [super dealloc];
}

- (void)doMatingDance
{
    NSMutableArray* keptOrgs = [NSMutableArray array];
    
    for (int orgIdx = 0; orgIdx < NUM_ORGS; orgIdx ++) {
        DrawOrganism* org = [orgs objectAtIndex:orgIdx];
        
        if (orgSelected[orgIdx]) {
            [keptOrgs addObject:org];
        }
    }
    
    for (int orgIdx = 0; orgIdx < NUM_ORGS; orgIdx ++) {
        if (!orgSelected[orgIdx]) {
            // if this organism isn't selected, and there are any selected, mate
            // two of random orgs which were selected. if nothing is selected, just
            // fill the spot with a new random organism.
            if ([keptOrgs count] > 0) {
                DrawOrganism* org1 = [keptOrgs objectAtIndex:(random() % [keptOrgs count])];
                DrawOrganism* org2 = [keptOrgs objectAtIndex:(random() % [keptOrgs count])];
                
                DrawOrganism* newChild = [[org1 mate:org2 andMutate:TRUE withWorld:world] autorelease];
                
                [orgs replaceObjectAtIndex:orgIdx withObject:newChild];
            }
            else {
                DrawOrganism* newChild = [[self newRandomOrg] autorelease];
                [orgs replaceObjectAtIndex:orgIdx withObject:newChild];
            }
        }
    }
}

- (void)drawView:(id)sender
{
    //GLfloat red[] = { 1.0f, 0.0f, 0.0f, 1.0f };
    //GLfloat green[] = { 0.0f, 1.0f, 0.0f, 1.0f };
    //GLfloat yellow[] = { 1.0f, 1.0f, 0.0f, 1.0f };
        
    NSMutableString* orgStr = [NSMutableString string];
    NSMutableString* selStr = [NSMutableString string];
    GLfloat columnWidth = 2.0f / (GLfloat)ORGSX;
    GLfloat rowHeight = (2.0f / (GLfloat)ORGSY) * (1.0 - STATUS_HEIGHT_PERCENTAGE); // save 30% for other stuff.
    
    for (int orgY = 0; orgY < ORGSY; orgY ++) {
        for (int orgX = 0; orgX < ORGSX; orgX ++) {
            int orgIdx = orgY * ORGSX + orgX;
            
            DrawState* drawState = [DrawState new];
            // start at the upper-left corner, and move right and down. down is negative,
            // so negate the rowHeight calculation.
            [drawState translate:CGPointMake(-1, 1)];
            [drawState translate:CGPointMake(columnWidth * orgX + columnWidth/2, -(rowHeight * orgY + rowHeight/2))];
            [drawState scale:CGPointMake(.10f, .10f * STATUS_HEIGHT_PERCENTAGE)];
            DrawOrganism* org = [orgs objectAtIndex:orgIdx];
            
            if (orgIdx == 0) {
                [orgView clear];
            }
            [orgView drawOrganism:org withSelected:orgSelected[orgIdx] withState:drawState];
            if (orgX == ORGSX-1 && orgY == ORGSY-1) {
                [orgView present];
            }
            
            [selStr appendFormat:@"%2d%@ ", orgIdx, orgSelected[orgIdx] ? @"*" : @" "];
            [orgStr appendFormat:@"org %d: fitness %.2f: %@\n", orgIdx, org.fitness, [org short_description]];
            
            [drawState release];
        }
    }

    textView.text = [NSString stringWithFormat:@"%@%@%@", status, selStr, orgStr];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [[event touchesForView:self] anyObject];
    CGPoint location = [touch locationInView:self];
    CGRect bounds = [self bounds];
    
    int xpos = (int) ((float) ORGSX * location.x  / (float) bounds.size.width);
    int ypos = (int) ((float) ORGSY * location.y  / (float) bounds.size.height / (1.0 - STATUS_HEIGHT_PERCENTAGE));
    
    NSString* otherStatus = nil;
    
    if (xpos < ORGSX && ypos < ORGSY) {
        int idx = ypos*ORGSX+xpos;
        orgSelected[idx] = !orgSelected[idx];
        otherStatus = [NSString stringWithFormat:@"org click, idx = %d", idx];
    }
    else if (xpos < ORGSX && ypos >= ORGSY) {
        if (xpos == 0) {
            otherStatus = @"resetting all";
            
            for (int orgIdx = 0; orgIdx < NUM_ORGS; orgIdx ++) {
                if (!orgSelected[orgIdx]) {
                    [orgs replaceObjectAtIndex:orgIdx withObject:[self newRandomOrg]];
                }
            }
            
        }
        else if (xpos == 1) {
            otherStatus = @"mating";
            
            [self doMatingDance];
        }
        else {
            // nothing, just redraw
            otherStatus = @"redraw";
        }

    }
    
    status = [NSString stringWithFormat:@"%@ -- xpos = %d, ypos = %d :: location.x = %f, location.y = %f\n", otherStatus, xpos, ypos, location.x, location.y];
    [self drawView:nil];
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
            //[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        }
        else {
            animationTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)((1.0 / 60.0) * animationFrameInterval) target:self selector:@selector(drawView:) userInfo:nil repeats:TRUE];
        }
        
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

@end

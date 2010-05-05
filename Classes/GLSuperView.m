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

#define ORGSX 3
#define ORGSY 3
#define NUM_ORGS ORGSX*ORGSY

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
        
        status = @"";
        
        // A system version of 3.1 or greater is required to use CADisplayLink. The NSTimer
        // class is used as fallback when it isn't available.
        NSString *reqSysVer = @"3.1";
        NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
        if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
            displayLinkSupported = TRUE;
		
        world = [[WorldParams alloc] init];
        world.mutationRate = .02f; // 2% mutation rate.

        orgs = [NSMutableArray new];
        orgSelected = (BOOL*) malloc(sizeof(BOOL) * NUM_ORGS);
        
        for (int i = 0; i < NUM_ORGS; i ++) {
            DrawOrganism* newOrg = [[DrawOrganism alloc] initEmpty];

            [orgs addObject:newOrg];
            [newOrg release];
            
            orgSelected[i] = FALSE;
            
            for (int gene = 0; gene < 300; gene ++) {
                DrawGene* newGene = [DrawGene randomGene];
                [newOrg addGene:newGene];
                [newGene release];
            }
		}
        
    }
    
    return self;
}

-(void) dealloc {
    [orgs release];
    [status release];
    [super dealloc];
}

- (void)drawView:(id)sender
{
    DrawOrganism* org1 = [orgs objectAtIndex:(random() % NUM_ORGS)];
    DrawOrganism* org2 = [orgs objectAtIndex:(random() % NUM_ORGS)];
    
    DrawOrganism* child = [org1 mate:org2 andMutate:true withWorld:world];

    GLfloat red[] = { 1.0f, 0.0f, 0.0f, 1.0f };
    //GLfloat green[] = { 0.0f, 1.0f, 0.0f, 1.0f };
    //GLfloat yellow[] = { 1.0f, 1.0f, 0.0f, 1.0f };
        
    DrawOrganism* killit = nil;
    CGFloat worstFitness = 0;
    int worstOrgIndex = 0;
    
    NSMutableString* orgStr = [NSMutableString string];
    NSMutableString* selStr = [NSMutableString string];
    CGFloat fitness[NUM_ORGS];
    GLfloat columnWidth = 2.0f / (GLfloat)ORGSX;
    GLfloat rowHeight = 2.0f / (GLfloat)ORGSY;
    
    for (int orgY = 0; orgY < ORGSY; orgY ++) {
        for (int orgX = 0; orgX < ORGSX; orgX ++) {
            int orgIdx = orgY * ORGSX + orgX;
            
            DrawState* drawState = [DrawState new];
            [drawState translate:CGPointMake(-1, -1)];
            [drawState translate:CGPointMake(columnWidth * orgX + columnWidth/2, rowHeight * orgY + rowHeight/2)];
            [drawState scale:CGPointMake(.10f, .10f)];
            
            DrawOrganism* org = [orgs objectAtIndex:orgIdx];
            
            fitness[orgIdx] = [orgView drawOrganism:org andClear:(orgIdx == 0) withState:drawState];
            
            [selStr appendFormat:@"org %d %@, ", orgIdx, orgSelected[orgIdx] ? @"sel" : @""];
            [orgStr appendFormat:@"org %d: fitness %.2f: %@\n", orgIdx, fitness[orgIdx], [org short_description]];

            
            if (killit == nil || fitness[orgIdx] < worstFitness) {
                worstFitness = fitness[orgIdx];
                worstOrgIndex = orgIdx;
                killit = org;
            }
            
            [drawState release];
            
            // draw the child in the last slot .. this is wonky.
            if (orgIdx == NUM_ORGS - 1) {
                DrawState* childDrawState = [DrawState new];
                [childDrawState translate:CGPointMake(-1, -1)];
                [childDrawState translate:CGPointMake(columnWidth * orgX + columnWidth/2, rowHeight * orgY + 1*rowHeight/4)];
                [childDrawState scale:CGPointMake(.10f, .10f)];
                childDrawState.color = red;
                
                GLfloat childFitness = [orgView drawOrganism:child andClear:FALSE withState:childDrawState];
                [orgStr appendFormat:@"child: fitness %.2f: %@\n", childFitness, [child short_description]];
                if (childFitness < worstFitness) {
                    killit = child;
                }
                [childDrawState release];
            }
        }
    }
    
    textView.text = [NSString stringWithFormat:@"%@%@%@", status, selStr, orgStr];
    
    if (killit != child) {
        [orgs replaceObjectAtIndex:worstOrgIndex withObject:child];
    }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch = [[event touchesForView:self] anyObject];
    CGPoint location = [touch locationInView:self];
    CGRect bounds = [self bounds];
    
    int xpos = (int) ((float) ORGSX * location.x  / (float) bounds.size.width);
    int ypos = (int) ((float) ORGSY * location.y  / (float) bounds.size.height);
    
    if (xpos < ORGSX && ypos < ORGSY) {
        int idx = ypos*ORGSX+xpos;
        orgSelected[idx] = !orgSelected[idx];
    }
    
    status = [NSString stringWithFormat:@"xpos = %d, ypos = %d :: location.x = %f, location.y = %f\n", xpos, ypos, location.x, location.y];
    
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

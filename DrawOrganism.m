//
//  DrawOrganism.m
//  Evo1
//
//  Created by Tim Hinderliter on 4/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

#import "DrawOrganism.h"
#import "DrawGene.h"
#import "DrawState.h"

@implementation DrawOrganism

@synthesize fitness;

- (GLfloat) drawGL {
	DrawState* drawState = [DrawState new];
    GLfloat result = [self drawGLWithState:drawState];
    [drawState release];
    
    return result;
}

    
- (GLfloat) drawGLWithState:(DrawState*)drawState {
	MachineState* machine = [[MachineState alloc] init:4];
    
    CGFloat minX = 0, minY = 0;
    CGFloat maxX = 0, maxY = 0;
    
    glColor4f(drawState.color[0], drawState.color[1], drawState.color[2], drawState.color[3]);

    int numStepsExecuted = 0;
	int index, nextIndex = 0;
    for (index = 0; index < [[self genes] count] && numStepsExecuted < 5000; index = nextIndex) {
	    DrawGene* gene = [[self genes] objectAtIndex:index];
        nextIndex = index + 1;
        ++ numStepsExecuted;
        
		CGPoint tempPoint;
        
		switch ([gene type]) {
			case NUMBER:
				[machine push:[gene number]];
				break;
				
			case CLONE1:
			case CLONE2:
			case CLONE3:
			case CLONE4:
				// assuming the CLONE1...CLONE4 enums are consequitive, clone such that
				// CLONE1 = 1, ...
				[machine clone:([gene type] - CLONE1 + 1)];
				break;

			case POP:
				[machine pop];
				break;
                
            case LOAD_R1:
            case LOAD_R2:
            case LOAD_R3:
            case LOAD_R4: {
                int reg = [gene type] - LOAD_R1;
                [machine setReg:reg withValue:[gene number]];
                break;
            }
                
            case STORE_R1:
            case STORE_R2:
            case STORE_R3:
            case STORE_R4:
				NSLog(@"error - STORE not implemented");
                break;
                
			case ADD:
                [machine setReg:2
                      withValue:[machine getReg:0] + [machine getReg:1]];
				break;
				
			case SUBTRACT:
                [machine setReg:2
                      withValue:[machine getReg:0] - [machine getReg:1]];
				break;
				
			case MULTI:
                [machine setReg:2
                      withValue:[machine getReg:0] * [machine getReg:1]];
				break;
				
			case DIV:
                [machine setReg:2
                      withValue:[machine getReg:0] / [machine getReg:1]];
				break;
				
			case TRANSLATE:
				tempPoint.x = [machine getReg:2];
				tempPoint.y = [machine getReg:3];
				[drawState translate:tempPoint];
				break;
				
			case ROTATE:
				[drawState rotate:[machine getReg:3]];
				break;
				
			case RGBA: {
                GLfloat color[4];
                for (int i = 0; i < 4; i ++) {
                    color[i] = [machine getReg:i];
                }
                
                [drawState setColor:color];
				break;
            }
				
			case SCALE:
				tempPoint.x = [machine getReg:2] * 2;
				tempPoint.y = [machine getReg:3] * 2;
				[drawState scale:tempPoint];
				break;
				
			case CMP: {
                GLfloat first = [machine getReg:0];
                GLfloat second = [machine getReg:1];
                if (first < second) {
                    [machine setReg:3 withValue:0];
                }
                else if (first == second) {
                    [machine setReg:3 withValue:.5f];
                }
                else {
                    [machine setReg:3 withValue:1.0f];
                }
                
				break;
            }
                
            case JMP_LTE: {
                CGFloat numIntoCode = [machine getReg:3];
                CGFloat floatIndexIntoCode = (CGFloat) [[self genes] count] * numIntoCode;
                int indexIntoCode = ((int)floatIndexIntoCode) % [[self genes] count];
                
                if ([machine getReg:3] <= .5f) {
                    nextIndex = indexIntoCode;
                }
                break;
            }
				
			case DRAW: {
                CGPoint bottomCorner, upperCorner, rightCorner;
                bottomCorner.x = bottomCorner.y = 0;
                upperCorner.x = 0; upperCorner.y = 1;
                rightCorner.x = 1; rightCorner.y = 0;
                
				bottomCorner = [drawState transformedPoint:bottomCorner];
                upperCorner = [drawState transformedPoint:upperCorner];
                rightCorner = [drawState transformedPoint:rightCorner];
                
                // update min/max if we're within normal drawing bounds.
                if (drawState.translate.x > -10 && drawState.translate.x < 10 &&
                    drawState.translate.y > -10 & drawState.translate.y < 10) {
                    minX = minX < drawState.translate.x ? minX : drawState.translate.x;
                    minY = minY < drawState.translate.y ? minY : drawState.translate.y;
                    maxX = maxX > drawState.translate.x ? maxX : drawState.translate.x;
                    maxY = maxY > drawState.translate.y ? maxY : drawState.translate.y;
                }
                
                CGFloat width = drawState.translate.x, height = drawState.translate.y;
                GLfloat vertices[] = {
                    (GLfloat) bottomCorner.x + width, (GLfloat) bottomCorner.y + height,
                    (GLfloat) upperCorner.x + width, (GLfloat) upperCorner.y + height,
                    (GLfloat) rightCorner.x + width, (GLfloat) rightCorner.y + height
                };
                
                glColor4f(drawState.color[0], drawState.color[1], drawState.color[2], drawState.color[3]);

                glVertexPointer(2, GL_FLOAT, 0, vertices);
                glDrawArrays(GL_TRIANGLE_FAN, 0, 3);
                
				break;
            }
                
			default:
				break;
		}
	}
    
    [machine release];
    
    fitness = (maxX - minX) + (maxY - minY);
    return fitness;
}


@end

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

- (CGFloat) drawGL {
	MachineState* machine = [MachineState new];
	DrawState* drawState = [DrawState new];
    
//    NSString *drewIt = @"";
    
    CGFloat minX = 0, minY = 0;
    CGFloat maxX = 0, maxY = 0;

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
				
			case ADD:
				[machine push:([machine pop] + [machine pop])];
				break;
				
			case SUBTRACT:
				[machine push:([machine pop] - [machine pop])];
				break;
				
			case MULTI:
				[machine push:([machine pop] * [machine pop])];
				break;
				
			case DIV:
				[machine push:([machine pop] / [machine pop])];
				break;
				
			case TRANSLATE:
				tempPoint.x = [machine pop];
				tempPoint.y = [machine pop];
				[drawState translate:tempPoint];
				break;
				
			case ROTATE:
				[drawState rotate:[machine pop]];
				break;
				
			case RGBA:
				//[drawState setColor:color];
				break;
				
			case SCALE:
				tempPoint.x = [machine pop] * 2;
				tempPoint.y = [machine pop] * 2;
				[drawState scale:tempPoint];
				break;
				
			case CMP:
				[machine compareTopTwo]; // will set the machine compare field too
				break;
                
            case JMP_LTE: {
                CGFloat numIntoCode = [machine pop];
                CGFloat floatIndexIntoCode = (CGFloat) [[self genes] count] * numIntoCode;
                int indexIntoCode = ((int)floatIndexIntoCode) % [[self genes] count];
                
                if ([machine lastCompareResult] == LESSTHAN || [machine lastCompareResult] == EQUAL) {
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
                
                glVertexPointer(2, GL_FLOAT, 0, vertices);
                glDrawArrays(GL_TRIANGLE_FAN, 0, 3);
                
                //drewIt = [NSString stringWithFormat:@"%@drew %f,%f -- %f,%f -- %f,%f || ",
                //          drewIt, vertices[0], vertices[1], vertices[2], vertices[3], vertices[4], vertices[5]];
				break;
            }
                
			default:
				break;
		}
	}
    
//    NSString* result = [NSString stringWithFormat:@"end result (DRAW %@) (MACHINE %@) %@",
//                        drawState, machine, drewIt];
    
    [machine release];
    [drawState release];
    
    //return result;
    // return range of places drawn.
    return (maxX - minX) + (maxY - minY);
}


@end

//
//  Vector.m
//  TouchOpenGLDemo
//
//  Created by Jonathan Wight on 7/2/12.
//  Copyright (c) 2012 Jonathan Wight. All rights reserved.
//

#import "Vector.h"

GLfloat Vector3fLength(Vector3f inVector)
    {
    return(sqrt(inVector.x * inVector.x + inVector.y * inVector.y + inVector.z * inVector.z));
    }

Vector3f Vector3fCrossProduct(Vector3f inLHS, Vector3f inRHS)
    {
    Vector3f theCrossProduct = {
        .x = inLHS.y * inRHS.z - inLHS.z * inRHS.y,
        .y = inLHS.z * inRHS.x - inLHS.x * inRHS.z,
        .z = inLHS.x * inRHS.y - inLHS.y * inRHS.x,
        };
    return(theCrossProduct);
    }

Vector3f Vector3fAdd(Vector3f inLHS, Vector3f inRHS)
    {
    Vector3f theVector = {
        .x = inLHS.x + inRHS.x,
        .y = inLHS.y + inRHS.y,
        .z = inLHS.z + inRHS.z,
        };
    return(theVector);
    }
    
Vector3f Vector3fFromVector4f(Vector4f inVector)
    {
    Vector3f theVector = {
        .x = inVector.x,
        .y = inVector.y,
        .z = inVector.z
        };
    return(theVector);
    }
    
GLfloat Vector3fDotProduct(Vector3f inLHS, Vector3f inRHS)
    {
    return(inLHS.x * inRHS.x + inLHS.y * inRHS.y + inLHS.z * inRHS.z);
    }

Vector3f Vector3fNormalize(Vector3f inVector)
    {
    const GLfloat theLength = Vector3fLength(inVector);
    return((Vector3f){
        .x = inVector.x / theLength, 
        .y = inVector.y / theLength, 
        .z = inVector.z / theLength, 
        });
    }
    
NSString *NSStringFromVector3f(Vector3f inVector)
	{
	return([NSString stringWithFormat:@"(%g, %g, %g)", inVector.x, inVector.y, inVector.z]);
	}
    
NSString *NSStringFromVector4f(Vector4f inVector)
	{
	return([NSString stringWithFormat:@"(%g, %g, %g, %g)", inVector.x, inVector.y, inVector.z, inVector.w]);
	}

NSString *NSStringFromColor4f(Color4f inColor)
    {
	return([NSString stringWithFormat:@"(%g, %g, %g, %g)", inColor.r, inColor.g, inColor.b, inColor.a]);
    }
		
Color4f Color4fFromPropertyListRepresentation(id inPropertyListRepresentation)
    {
	Color4f theColor = { .a = 1.0 };
	NSArray *theArray = NULL;
	
	if ([inPropertyListRepresentation isKindOfClass:[NSString class]])
		{
        theArray = [inPropertyListRepresentation componentsSeparatedByString:@","];
        }
	else if ([inPropertyListRepresentation isKindOfClass:[NSArray class]])
		{
        theArray = inPropertyListRepresentation;
		}

    theColor.r = [[theArray objectAtIndex:0] doubleValue];
    theColor.g = [[theArray objectAtIndex:1] doubleValue];
    theColor.b = [[theArray objectAtIndex:2] doubleValue];
    if ([theArray count] == 4)
        {
        theColor.a = [[theArray objectAtIndex:3] doubleValue];
        }
    
    return(theColor);
    }
        
Vector3f Vector3fFromPropertyListRepresentation(id inPropertyListRepresentation)
    {
	Vector3f theVector;
	NSArray *theArray = NULL;
	
	if ([inPropertyListRepresentation isKindOfClass:[NSString class]])
		{
        theArray = [inPropertyListRepresentation componentsSeparatedByString:@","];
        }
	else if ([inPropertyListRepresentation isKindOfClass:[NSArray class]])
		{
        theArray = inPropertyListRepresentation;
		}

    theVector.x = [[theArray objectAtIndex:0] doubleValue];
    theVector.y = [[theArray objectAtIndex:1] doubleValue];
    theVector.z = [[theArray objectAtIndex:2] doubleValue];
    
    return(theVector);
    }

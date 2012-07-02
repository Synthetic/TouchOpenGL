//
//  Vector.m
//  TouchOpenGLDemo
//
//  Created by Jonathan Wight on 7/2/12.
//  Copyright (c) 2012 Jonathan Wight. All rights reserved.
//

#import "Vector.h"

GLfloat Vector3Length(Vector3 inVector)
    {
    return(sqrt(inVector.x * inVector.x + inVector.y * inVector.y + inVector.z * inVector.z));
    }

Vector3 Vector3CrossProduct(Vector3 inLHS, Vector3 inRHS)
    {
    Vector3 theCrossProduct = {
        .x = inLHS.y * inRHS.z - inLHS.z * inRHS.y,
        .y = inLHS.z * inRHS.x - inLHS.x * inRHS.z,
        .z = inLHS.x * inRHS.y - inLHS.y * inRHS.x,
        };
    return(theCrossProduct);
    }

Vector3 Vector3Add(Vector3 inLHS, Vector3 inRHS)
    {
    Vector3 theVector = {
        .x = inLHS.x + inRHS.x,
        .y = inLHS.y + inRHS.y,
        .z = inLHS.z + inRHS.z,
        };
    return(theVector);
    }
    
Vector3 Vector3FromVector4(Vector4 inVector)
    {
    Vector3 theVector = {
        .x = inVector.x,
        .y = inVector.y,
        .z = inVector.z
        };
    return(theVector);
    }
    
GLfloat Vector3DotProduct(Vector3 inLHS, Vector3 inRHS)
    {
    return(inLHS.x * inRHS.x + inLHS.y * inRHS.y + inLHS.z * inRHS.z);
    }

Vector3 Vector3Normalize(Vector3 inVector)
    {
    const GLfloat theLength = Vector3Length(inVector);
    return((Vector3){
        .x = inVector.x / theLength, 
        .y = inVector.y / theLength, 
        .z = inVector.z / theLength, 
        });
    }
    
NSString *NSStringFromVector3(Vector3 inVector)
	{
	return([NSString stringWithFormat:@"(%g, %g, %g)", inVector.x, inVector.y, inVector.z]);
	}
    
NSString *NSStringFromVector4(Vector4 inVector)
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
        
Vector3 Vector3FromPropertyListRepresentation(id inPropertyListRepresentation)
    {
	Vector3 theVector;
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

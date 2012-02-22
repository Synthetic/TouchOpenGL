//
//  CVertexBuffer_PropertyListRepresentation.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 03/21/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are
//  permitted provided that the following conditions are met:
//
//     1. Redistributions of source code must retain the above copyright notice, this list of
//        conditions and the following disclaimer.
//
//     2. Redistributions in binary form must reproduce the above copyright notice, this list
//        of conditions and the following disclaimer in the documentation and/or other materials
//        provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY JONATHAN WIGHT ``AS IS'' AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JONATHAN WIGHT OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those of the
//  authors and should not be interpreted as representing official policies, either expressed
//  or implied, of toxicsoftware.com.

#import "CVertexBuffer_PropertyListRepresentation.h"

#import "OpenGLTypes.h"
#import "NSData_NumberExtensions.h"

#define NO_DEFAULTS 1

@implementation CVertexBuffer (CVertexBuffer_PropertyListRepresentation)

- (id)initWithPropertyListRepresentation:(id)inRepresentation error:(NSError **)outError;
    {
    NSString *theString = [(NSDictionary *)inRepresentation objectForKey:@"target"];
    NSAssert(NO_DEFAULTS && theString.length > 0, @"No target specified.");
    GLenum theTarget = GLenumFromString(theString) ?: GL_ARRAY_BUFFER;
    
    theString = [(NSDictionary *)inRepresentation objectForKey:@"usage"];
    NSAssert(NO_DEFAULTS && theString.length > 0, @"No usage specified.");
    GLenum theUsage = GLenumFromString(theString) ?: GL_STATIC_DRAW;
    
    NSData *theData = NULL;

    if ((theString = [(NSDictionary *)inRepresentation objectForKey:@"floats"]) != NULL && theString.length > 0)
        {
        theData = [NSData dataWithNumbersInString:theString type:kCFNumberFloat32Type error:outError];
        if (theData == NULL)
            {
            return(NULL);
            }
        }
    else if ((theString = [(NSDictionary *)inRepresentation objectForKey:@"shorts"]) != NULL && theString.length > 0)
        {
        theData = [NSData dataWithNumbersInString:theString type:kCFNumberShortType error:outError];
        if (theData == NULL)
            {
            return(NULL);
            }
        }
    else
        {
        NSString *theHREF = [(NSDictionary *)inRepresentation objectForKey:@"href"];
        
        NSURL *theURL = [[NSBundle mainBundle] URLForResource:theHREF withExtension:NULL];
        theData = [NSData dataWithContentsOfURL:theURL];
        }

	if ((self = [self initWithTarget:theTarget usage:theUsage data:theData]) != NULL)
		{
		}
	return(self);
	}

@end

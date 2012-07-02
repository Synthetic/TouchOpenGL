//
//  OpenGLTypes.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 1/1/2000.
//  Copyright 2012 Jonathan Wight. All rights reserved.
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
//  or implied, of Jonathan Wight.

#import "OpenGLTypes.h"

#include <tgmath.h>

GLfloat DegreesToRadians(GLfloat inDegrees)
	{
	return(inDegrees * M_PI / 180.0);
	}

GLfloat RadiansToDegrees(GLfloat inDegrees)
	{
	return(inDegrees * 180.0 / M_PI);
	}

    
GLenum GLenumFromString(NSString *inString)
    {
    // TODO obviously this needs to be massively expanded.
    if ([inString isEqualToString:@"GL_ARRAY_BUFFER"])
        {
        return(GL_ARRAY_BUFFER);
        }
    if ([inString isEqualToString:@"GL_ELEMENT_ARRAY_BUFFER"])
        {
        return(GL_ELEMENT_ARRAY_BUFFER);
        }
    else if ([inString isEqualToString:@"GL_STATIC_DRAW"])
        {
        return(GL_STATIC_DRAW);
        }
    else if ([inString isEqualToString:@"GL_FLOAT"])
        {
        return(GL_FLOAT);
        }
    else if ([inString isEqualToString:@"GL_SHORT"])
        {
        return(GL_SHORT);
        }
    else if ([inString isEqualToString:@"GL_BACK"])
        {
        return(GL_BACK);
        }
    else if ([inString isEqualToString:@"GL_FRONT"])
        {
        return(GL_FRONT);
        }
    else if ([inString isEqualToString:@"GL_FRONT_AND_BACK"])
        {
        return(GL_FRONT_AND_BACK);
        }
    else if ([inString isEqualToString:@"GL_CULL_FACE"])
        {
        return(GL_CULL_FACE);
        }
    else
        {
        NSCAssert(NO, @"Unknown enum");
        }
        
    return(0);   
    }
    
NSString *NSStringFromGLenum(GLenum inEnum)
    {
    switch (inEnum)
        {
        case GL_NO_ERROR:
            return(@"GL_NO_ERROR");
        case GL_INVALID_ENUM:
            return(@"GL_INVALID_ENUM");
        case GL_INVALID_VALUE:
            return(@"GL_INVALID_VALUE");
        case GL_INVALID_OPERATION:
            return(@"GL_INVALID_OPERATION");
        case GL_OUT_OF_MEMORY:
            return(@"GL_OUT_OF_MEMORY");
		case GL_INVALID_FRAMEBUFFER_OPERATION: // 0x0506
			return(@"GL_INVALID_FRAMEBUFFER_OPERATION");
        case GL_ARRAY_BUFFER:
            return(@"GL_ARRAY_BUFFER");
        case GL_ELEMENT_ARRAY_BUFFER:
            return(@"GL_ELEMENT_ARRAY_BUFFER");
        case GL_STATIC_DRAW:
            return(@"GL_STATIC_DRAW");
        case GL_FLOAT:
            return(@"GL_FLOAT");
        case GL_SHORT:
            return(@"GL_SHORT");
		case GL_FRAMEBUFFER_COMPLETE:
			return(@"GL_FRAMEBUFFER_COMPLETE");
		case GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT:
			return(@"GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT");
		case GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT:
			return(@"GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT");
		case GL_FRAMEBUFFER_UNSUPPORTED:
			return(@"GL_FRAMEBUFFER_UNSUPPORTED");
		case GL_TEXTURE_2D:
			return(@"GL_TEXTURE_2D");
		case GL_RGBA:
			return(@"GL_RGBA");
		case GL_BGRA:
			return(@"GL_BGRA");
		case GL_UNSIGNED_BYTE:
			return(@"GL_UNSIGNED_BYTE");

		#if TARGET_OS_IPHONE == 1
		case GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS:
			return(@"GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS");
		#else
		case GL_TEXTURE_1D:
			return(@"GL_TEXTURE_1D");
		case GL_TEXTURE_RECTANGLE_ARB:
			return(@"GL_TEXTURE_RECTANGLE_ARB");
		#endif /* if TARGET_OS_IPHONE == 1 */
		
		case GL_TEXTURE_MIN_FILTER:
			return(@"GL_TEXTURE_MIN_FILTER");
		case GL_TEXTURE_MAG_FILTER:
			return(@"GL_TEXTURE_MAG_FILTER");
		case GL_LINEAR:
			return(@"GL_LINEAR");
		case GL_TEXTURE_WRAP_S:
			return(@"GL_TEXTURE_WRAP_S");
		case GL_TEXTURE_WRAP_T:
			return(@"GL_TEXTURE_WRAP_T");
		case GL_CLAMP_TO_EDGE:
			return(@"GL_CLAMP_TO_EDGE");
        case GL_VERTEX_SHADER:
            return(@"GL_VERTEX_SHADER");
        case GL_FRAGMENT_SHADER:
            return(@"GL_FRAGMENT_SHADER");
        }
    return([NSString stringWithFormat:@"%X", inEnum]);
    }

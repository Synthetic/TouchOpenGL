//
//  CTexture.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 09/06/10.
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

#import "CTexture.h"

//static int gCount = 0;

@interface CTexture ()
@property (readwrite, nonatomic, assign) BOOL owns;
@end

@implementation CTexture

@synthesize target = _target;
@synthesize format = _format;
@synthesize type = _type;
@synthesize size = _size;

@synthesize owns = _owns;

- (id)initWithName:(GLuint)inName target:(GLenum)inTarget size:(SIntSize)inSize format:(GLenum)inFormat type:(GLenum)inType owns:(BOOL)inOwns;
	{
    if ((self = [super initWithName:inName]) != NULL)
        {
		_target = inTarget;
        _size = inSize;
		_format = inFormat;
		_type = inType;
        _owns = inOwns;
        }
    return(self);
	}

- (id)initWithTarget:(GLenum)inTarget size:(SIntSize)inSize format:(GLenum)inFormat type:(GLenum)inType;
	{
	AssertOpenGLValidContext_();
	AssertOpenGLNoError_();

	if (inSize.width != inSize.height)
		{
//		NSLog(@"WARNING: Texture request isn't square.");
		}
	
	GLuint theTextureName;
	glGenTextures(1, &theTextureName);

	glBindTexture(inTarget, theTextureName);
	glTexImage2D(inTarget, 0, inFormat, inSize.width, inSize.height, 0, inFormat, inType, NULL); 
	glTexParameteri(inTarget, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(inTarget, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(inTarget, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(inTarget, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);   

	AssertOpenGLNoError_();

    if ((self = [self initWithName:theTextureName target:inTarget size:inSize format:inFormat type:inType owns:YES]) != NULL)
        {
        }
    return(self);
	}

- (NSString *)description
    {
	[self bind];
	
	GLint theMinFilterParam;
	glGetTexParameteriv(self.target, GL_TEXTURE_MIN_FILTER, &theMinFilterParam);
	GLint theMagFilterParam;
	glGetTexParameteriv(self.target, GL_TEXTURE_MAG_FILTER, &theMagFilterParam);
	GLint theWrapSParam;
	glGetTexParameteriv(self.target, GL_TEXTURE_WRAP_S, &theWrapSParam);
	GLint theWrapTParam;
	glGetTexParameteriv(self.target, GL_TEXTURE_WRAP_T, &theWrapTParam);
	
	NSDictionary *theAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
		NSStringFromGLenum(self.target), @"target",
		NSStringFromGLenum(self.name), @"name",
		[NSString stringWithFormat:@"%d x %d", self.size.width, self.size.height], @"size",
		NSStringFromGLenum(self.format), @"format",
		NSStringFromGLenum(self.type), @"type",
		NSStringFromGLenum(theMinFilterParam), @"GL_TEXTURE_MIN_FILTER",
		NSStringFromGLenum(theMagFilterParam), @"GL_TEXTURE_MAG_FILTER",
		NSStringFromGLenum(theWrapSParam), @"GL_TEXTURE_WRAP_S",
		NSStringFromGLenum(theWrapTParam), @"GL_TEXTURE_WRAP_T",
        NULL];

    return([NSString stringWithFormat:@"%@ %@", [super description], theAttributes]);
    }

- (GLuint)cost
	{
	return(self.size.width * self.size.height);
	}

- (void)invalidate
	{
	AssertOpenGLValidContext_();

    if (_owns == YES)
        {
		GLuint theName = self.name;
        glDeleteTextures(1, &theName);
		_owns = NO;
		
//		NSLog(@"DELETED");
        }

	[super invalidate];
	}

- (BOOL)isValid
    {
    return(glIsTexture(self.name));
    }

- (void)bind
	{
	glBindTexture(self.target, self.name);
	}

- (void)use:(GLuint)inUniform index:(GLuint)inIndex
	{
	AssertOpenGLValidContext_();
	
	glActiveTexture(GL_TEXTURE0 + inIndex);
	glBindTexture(self.target, self.name);
	glUniform1i(inUniform, inIndex);
	AssertOpenGLNoError_();
	}

- (void)set:(Color4f)inColor;
	{
	[self bind];

	AssertOpenGLNoError_();
	
	NSMutableData *theData = [NSMutableData dataWithLength:self.size.width * 4 * self.size.height];
	const Color4ub theColor = {
		.r = (GLubyte)( inColor.r * 255.0 ),
		.g = (GLubyte)( inColor.g * 255.0 ),
		.b = (GLubyte)( inColor.b * 255.0 ),
		.a = (GLubyte)( inColor.a * 255.0 ),
		};
	Color4ub *P = [theData mutableBytes];
	for (GLint N = 0; N != self.size.width * self.size.height; ++N)
		{
		*P++ = theColor;
		}

	glTexSubImage2D(self.target, 0, 0, 0, self.size.width, self.size.height, self.format, self.type, [theData mutableBytes]);

	AssertOpenGLNoError_();
	}


+ (BOOL)debug
	{
	return(NO);
	}
    
@end

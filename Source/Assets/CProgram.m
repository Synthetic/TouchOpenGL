//
//  CProgram.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 09/05/10.
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

#import "CProgram.h"

#import "OpenGLTypes.h"
#import "CShader.h"
#import "CAssetLibrary.h"

@interface CProgram ()
@property (readwrite, nonatomic, copy) NSMutableDictionary *uniformsByName;
@end

#pragma mark -

@implementation CProgram

- (id)initWithShaders:(NSArray *)inShaders
    {
    #pragma unused (inUniformNames)
    // TODO: Clean this inUniformNames

	AssertOpenGLNoError_();

    // Create shader program
    GLuint theName = glCreateProgram();

    if ((self = [self initWithName:theName]) != NULL)
        {
		_shaders = inShaders;
		
		for (CShader *theShader in _shaders)
			{
			[self attachShader:theShader];
			}
		
        _uniformsByName = [[NSMutableDictionary alloc] init];
        }
    return(self);
    }
	

- (void)invalidate
    {
    if (self.named && glIsProgram(self.name))
        {
		GLuint theName = self.name;
        glDeleteProgram(theName);
        }
		
	[super invalidate];
    }

#pragma mark -

- (void)bindAttribute:(NSString *)inName location:(GLuint)inLocation;
	{
	glBindAttribLocation(self.name, inLocation, [inName UTF8String]);
	}

- (void)attachShader:(CShader *)inShader
	{
    AssertOpenGLNoError_();
	
	glAttachShader(self.name, inShader.name);
    AssertOpenGLNoError_();

	inShader.program = self;
	}
	
- (void)detachShader:(CShader *)inShader
	{
	[self reset];
	
    AssertOpenGLNoError_();
	glDetachShader(self.name, inShader.name);
    AssertOpenGLNoError_();

	inShader.program = NULL;
	}

#pragma mark -

- (BOOL)linkProgram:(NSError **)outError
    {
    AssertOpenGLNoError_();

    // Link program
    glLinkProgram(self.name);

    GLint theStatus = GL_FALSE;
    glGetProgramiv(self.name, GL_LINK_STATUS, &theStatus);
    if (theStatus == GL_FALSE)
        {
        NSMutableDictionary *theUserInfo = [NSMutableDictionary dictionary];
        GLint theLogLength;
        glGetProgramiv(self.name, GL_INFO_LOG_LENGTH, &theLogLength);
        if (theLogLength > 0)
            {
            GLchar *theLogStringBuffer = (GLchar *)malloc(theLogLength);
            glGetProgramInfoLog(self.name, theLogLength, &theLogLength, theLogStringBuffer);
            [theUserInfo setObject:[NSString stringWithUTF8String:theLogStringBuffer] forKey:NSLocalizedDescriptionKey];
            free(theLogStringBuffer);
            }
        if (outError)
            {
            *outError = [NSError errorWithDomain:@"OpenGL" code:-1 userInfo:theUserInfo];
            }
        return(NO);
        }

    AssertOpenGLNoError_();
    
    return(YES);
    }

- (BOOL)validate:(NSError **)outError
    {
    AssertOpenGLNoError_();

    glValidateProgram(self.name);

    GLint theStatus = GL_FALSE;
    glGetProgramiv(self.name, GL_VALIDATE_STATUS, &theStatus);
    if (theStatus == GL_TRUE)
        {
        return(YES);
        }
    else
        {
        if (outError)
            {
            NSMutableDictionary *theUserInfo = [NSMutableDictionary dictionary];
            GLint theLogLength;
            glGetProgramiv(self.name, GL_INFO_LOG_LENGTH, &theLogLength);
            if (theLogLength > 0)
                {
                GLchar *theLogStringBuffer = (GLchar *)malloc(theLogLength);
                glGetProgramInfoLog(self.name, theLogLength, &theLogLength, theLogStringBuffer);
                [theUserInfo setObject:[NSString stringWithUTF8String:theLogStringBuffer] forKey:NSLocalizedDescriptionKey];
                free(theLogStringBuffer);
                }
            *outError = [NSError errorWithDomain:@"OpenGL" code:-1 userInfo:theUserInfo];
            }
        return(NO);
        }
    }

- (void)reset
	{
	self.uniformsByName = NULL;
	}

- (void)update
	{
	}
    
- (void)use
    {
    AssertOpenGLNoError_();
    glUseProgram(self.name);
    AssertOpenGLNoError_();
    }

#pragma mark -

- (GLuint)uniformIndexForName:(NSString *)inName
    {
    if ([self.uniformsByName objectForKey:inName] == NULL)
        {
        AssertOpenGLNoError_();
        GLint theLocation = glGetUniformLocation(self.name, [inName UTF8String]);
        if (theLocation == -1)
            {
            NSLog(@"Could not get uniform location for: %@", inName);
            #warning 0 is a valid uniform location
            return(0); 
            }
        
        AssertOpenGLNoError_();
        [self.uniformsByName setObject:[NSNumber numberWithInt:theLocation] forKey:inName];
        return(theLocation);
        }
    else
        {
        return([[self.uniformsByName objectForKey:inName] unsignedIntValue]);
        }
    }

#pragma mark -
    
+ (CShader *)loadShader:(NSString *)inName;
	{
	NSParameterAssert([COpenGLContext currentContext] != NULL);
	CShader *theShader = [[COpenGLContext currentContext].assetLibrary shaderNamed:inName error:NULL];
	return(theShader);
	}

@end

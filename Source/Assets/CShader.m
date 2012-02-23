//
//  CShader.m
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

#import "CShader.h"

#import "OpenGLTypes.h"
#import "CSimplePreprocessor.h"

@interface CShader ()
@property (readwrite, nonatomic, strong) NSURL *URL;
@property (readwrite, nonatomic, assign) GLuint name;
@end

#pragma mark -

@implementation CShader

@synthesize URL;
@synthesize name;

- (id)initWithURL:(NSURL *)inURL
    {
    if ([inURL isFileURL] == YES)
        {
        if ([[NSFileManager defaultManager] fileExistsAtPath:inURL.path] == NO)
            {
            self = NULL;
            return(NULL);
            }
        }

    if ((self = [super init]) != NULL)
        {
        URL = inURL;
        }
    return(self);
    }

- (id)initWithName:(NSString *)inName
    {
    NSURL *theURL = [[NSBundle mainBundle] URLForResource:[inName stringByDeletingPathExtension] withExtension:[inName pathExtension]];
    if (theURL == NULL)
        {
        theURL = [[[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:@"Shaders"] URLByAppendingPathComponent:inName];
        }
    if ((self = [self initWithURL:theURL]) != NULL)
        {
        }
    return(self);
    }

- (void)dealloc
    {
    if (glIsShader(name))
        {
        glDeleteShader(name);
        name = 0;
        }
    }

- (GLuint)name
    {
    if (name == 0)
        {
        [self compileShader:NULL];
        }
    return(name);
    }

- (NSString *)source
	{
	
	NSString *theSource = [NSString stringWithContentsOfURL:self.URL encoding:NSUTF8StringEncoding error:NULL];
	
	CSimplePreprocessor *thePreprocessor = [[CSimplePreprocessor alloc] init];
	thePreprocessor.loader = ^(NSString *inName) {
		NSURL *theURL = [[self.URL URLByDeletingLastPathComponent] URLByAppendingPathComponent:inName];
		NSString *theSource = [NSString stringWithContentsOfURL:theURL encoding:NSUTF8StringEncoding error:NULL];
		return(theSource);
		};
	theSource = [thePreprocessor preprocess:theSource error:NULL];
	return(theSource);
	}

- (BOOL)compileShader:(NSError **)outError
    {
    #pragma unused (outError)
    
    AssertOpenGLNoError_();
    
    GLint theStatus;
    const GLchar *theSource;

    theSource = (GLchar *)[self.source UTF8String];
    if (!theSource)
        {
        NSLog(@"Failed to load vertex shader");
        return FALSE;
        }

    AssertOpenGLNoError_();
        
    GLenum theType = 0;
    if ([[self.URL pathExtension] isEqualToString:@"fsh"])
        {
        theType = GL_FRAGMENT_SHADER;
        }
    else if ([[self.URL pathExtension] isEqualToString:@"vsh"])
        {
        theType = GL_VERTEX_SHADER;
        }
    else
        {
        return(NO);
        }

    AssertOpenGLNoError_();

    GLuint theName = glCreateShader(theType);
    glShaderSource(theName, 1, &theSource, NULL);
    glCompileShader(theName);

    AssertOpenGLNoError_();

#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(theName, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
        {
        GLchar *theLogBuffer = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(theName, logLength, &logLength, theLogBuffer);
        NSLog(@"Shader failed:\n%@", self.URL);
        NSLog(@"Shader compile log:\n%s", theLogBuffer);
        free(theLogBuffer);
        }
#endif

    AssertOpenGLNoError_();

    glGetShaderiv(theName, GL_COMPILE_STATUS, &theStatus);
    if (theStatus == 0)
        {
        glDeleteShader(theName);
        return FALSE;
        }

    AssertOpenGLNoError_();

    name = theName;

    return(TRUE);
    }

@end

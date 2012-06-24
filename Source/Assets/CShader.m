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

static BOOL gAbortsOnCompilationFailure = DEBUG;

@interface CShader ()
@property (readwrite, nonatomic, strong) NSURL *URL;
@end

#pragma mark -

@implementation CShader

@synthesize source = _source;
@synthesize program = _program;
@synthesize type = _type;
@synthesize URL = _URL;

- (id)initWithURL:(NSURL *)inURL error:(NSError **)outError
    {
    NSLog(@"LOADING: %@", [inURL lastPathComponent]);

    if ([inURL isFileURL] == YES)
        {
        if ([[NSFileManager defaultManager] fileExistsAtPath:inURL.path] == NO)
            {
			NSLog(@"No file at %@", inURL);
            self = NULL;
            return(NULL);
            }
        }

    GLenum theType = 0;
    if ([[inURL pathExtension] isEqualToString:@"fsh"])
        {
        theType = GL_FRAGMENT_SHADER;
        }
    else if ([[inURL pathExtension] isEqualToString:@"vsh"])
        {
        theType = GL_VERTEX_SHADER;
        }
    else
        {
		self = NULL;
		return(NULL);
        }

    GLuint theName = glCreateShader(theType);

    if ((self = [super initWithName:theName]) != NULL)
        {
		_type = theType;
        _URL = inURL;
		
		if ([self compileShader:outError] == NO)
			{
			self = NULL;
			return(self);
			}
        }
    return(self);
    }

- (void)invalidate
    {
    if (self.named && glIsShader(self.name))
        {
		GLuint theName = self.name;
        glDeleteShader(theName);
        }
		
	[super invalidate];
    }

- (NSString *)source
	{
	if (_source == NULL)
		{
		NSString *theSource = [NSString stringWithContentsOfURL:self.URL encoding:NSUTF8StringEncoding error:NULL];
		return(theSource);
		}
	return(_source);
	}

- (void)setSource:(NSString *)source
	{
	if (_source != source)
		{
		_source = source;

		[self compileShader:NULL];
		}
	}

- (NSString *)preprocessedSource
	{
	CSimplePreprocessor *thePreprocessor = [[CSimplePreprocessor alloc] init];
	thePreprocessor.loader = ^(NSString *inName) {
		NSURL *theURL = [[self.URL URLByDeletingLastPathComponent] URLByAppendingPathComponent:inName];
		NSString *theSource = [NSString stringWithContentsOfURL:theURL encoding:NSUTF8StringEncoding error:NULL];
		return(theSource);
		};
	NSString *theSource = [thePreprocessor preprocess:self.source error:NULL];
	return(theSource);
	}

- (BOOL)compileShader:(NSError **)outError
    {
    #pragma unused (outError)
    
    AssertOpenGLNoError_();
    
    GLint theStatus;
    const GLchar *theSource;

    theSource = (GLchar *)[self.preprocessedSource UTF8String];
    if (!theSource)
        {
        NSLog(@"Failed to load vertex shader");
        if (gAbortsOnCompilationFailure == YES)
            {
            abort();
            }
        return FALSE;
        }

    AssertOpenGLNoError_();
        
    AssertOpenGLNoError_();

    glShaderSource(self.name, 1, &theSource, NULL);
    glCompileShader(self.name);

    AssertOpenGLNoError_();

#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(self.name, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
        {
        GLchar *theLogBuffer = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(self.name, logLength, &logLength, theLogBuffer);
        NSLog(@"Shader failed:\n%@", self.URL);
        NSLog(@"Shader compile log:\n%s", theLogBuffer);
        free(theLogBuffer);
        if (gAbortsOnCompilationFailure == YES)
            {
            abort();
            }
        }
#endif

    AssertOpenGLNoError_();

    glGetShaderiv(self.name, GL_COMPILE_STATUS, &theStatus);
//    if (theStatus == 0)
//        {
//        glDeleteShader(self.name);
//        return FALSE;
//        }

    AssertOpenGLNoError_();

    return(TRUE);
    }

+ (void)setAbortsOnCompilationFailure:(BOOL)inFlag;
    {
    gAbortsOnCompilationFailure = inFlag;
    }

@end

//
//  CShader.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 09/06/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import "CShader.h"

#import "OpenGLTypes.h"

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
    //
    }

- (GLuint)name
    {
    if (name == 0)
        {
        [self compileShader:NULL];
        }
    return(name);
    }


- (BOOL)compileShader:(NSError **)outError
    {
    #pragma unused (outError)
    
    AssertOpenGLNoError_();
    
    GLint theStatus;
    const GLchar *theSource;

    theSource = (GLchar *)[[NSString stringWithContentsOfURL:self.URL encoding:NSUTF8StringEncoding error:nil] UTF8String];
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

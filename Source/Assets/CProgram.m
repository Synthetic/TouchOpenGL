//
//  CProgram.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 09/05/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import "CProgram.h"

#import "OpenGLTypes.h"
#import "CShader.h"

@interface CProgram ()
@property (readwrite, nonatomic, copy) NSArray *shaders;    
@property (readwrite, nonatomic, assign) GLuint name;

@property (readonly, nonatomic, copy) NSMutableDictionary *attributesByName;    
@property (readonly, nonatomic, copy) NSMutableDictionary *uniformsByName;
@end

#pragma mark -

@implementation CProgram

@synthesize shaders;
@synthesize name;

@synthesize attributesByName;
@synthesize uniformsByName;

- (id)initWithShaders:(NSArray *)inShaders attributeNames:(NSArray *)inAttributeNames uniformNames:(NSArray *)inUniformNames
    {
    #pragma unused (inUniformNames)
    // TODO: Clean this inUniformNames
    
    if ((self = [self init]) != NULL)
        {
        shaders = [inShaders copy];
        attributesByName = [[NSMutableDictionary alloc] init];
        uniformsByName = [[NSMutableDictionary alloc] init];
        name = 0;

        GLuint theAttributeIndex = 0;
        NSMutableDictionary *theAttributesByName = [NSMutableDictionary dictionary];
        for (NSString *theAttributeName in inAttributeNames)
            {
            [theAttributesByName setObject:[NSNumber numberWithUnsignedInt:theAttributeIndex++] forKey:theAttributeName];
            }
        attributesByName = [theAttributesByName mutableCopy];
        }
    return(self);
    }

- (void)dealloc
    {
    if (glIsProgram(name))
        {
        glDeleteProgram(name);
        name = 0;
        }
    }

#pragma mark -

- (GLuint)name
    {
    if (name == 0)
        {
        NSError *theError = NULL;
        if ([self linkProgram:&theError] == NO)
            {
            NSLog(@"linkProgram failed: %@", theError);
            }
        }
    return(name);
    }
    
#pragma mark -

- (BOOL)linkProgram:(NSError **)outError
    {
    AssertOpenGLNoError_();

    // Create shader program
    GLuint theProgramName = glCreateProgram();

    AssertOpenGLNoError_();
    
    // Attach shaders to program...
    for (CShader *theShader in self.shaders)
        {
        AssertOpenGLNoError_();
        NSAssert(theShader.name != 0, @"No shader name");
        glAttachShader(theProgramName, theShader.name);
        AssertOpenGLNoError_();
        }

    AssertOpenGLNoError_();
    
    // Bind attribute locations this needs to be done prior to linking
    for (NSString *theAttributeName in self.attributesByName)
        {
        GLuint theAttributeIndex = [[self.attributesByName objectForKey:theAttributeName] unsignedIntValue];
        glBindAttribLocation(theProgramName, theAttributeIndex, [theAttributeName UTF8String]);
        }

    AssertOpenGLNoError_();

    // Link program
    glLinkProgram(theProgramName);

    GLint theStatus = GL_FALSE;
    glGetProgramiv(theProgramName, GL_LINK_STATUS, &theStatus);
    if (theStatus == GL_FALSE)
        {
        NSMutableDictionary *theUserInfo = [NSMutableDictionary dictionary];
        GLint theLogLength;
        glGetProgramiv(theProgramName, GL_INFO_LOG_LENGTH, &theLogLength);
        if (theLogLength > 0)
            {
            GLchar *theLogStringBuffer = (GLchar *)malloc(theLogLength);
            glGetProgramInfoLog(theProgramName, theLogLength, &theLogLength, theLogStringBuffer);
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
    
    name = theProgramName;

    self.shaders = NULL;

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
    
- (void)use
    {
    AssertOpenGLNoError_();
    glUseProgram(self.name);
    AssertOpenGLNoError_();
    }

#pragma mark -

- (GLuint)attributeIndexForName:(NSString *)inName
    {
    NSNumber *theNumber = [self.attributesByName objectForKey:inName];
    if (theNumber == NULL)
        {
        GLuint theIndex = (GLuint)self.attributesByName.count;
        theNumber = [NSNumber numberWithUnsignedInt:theIndex];
        [self.attributesByName setObject:theNumber forKey:inName];
        return(theIndex);
        }
    else
        {
        return([theNumber unsignedIntValue]);
        }
    }
    
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

@end

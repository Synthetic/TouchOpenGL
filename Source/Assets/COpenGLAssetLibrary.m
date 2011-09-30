//
//  COpenGLAssetLibrary.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 03/14/11.
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

#import "COpenGLAssetLibrary.h"

#import <objc/runtime.h>

#import "CVertexBuffer.h"
#import "CProgram.h"
#import "CProgram_Extensions.h"

@interface COpenGLAssetLibrary ()
@property (readwrite, nonatomic, strong) NSCache *vertexBufferCache;
@property (readwrite, nonatomic, strong) NSCache *textureCache;
@property (readwrite, nonatomic, strong) NSCache *programCache;
@end

@implementation COpenGLAssetLibrary

@synthesize vertexBufferCache;
@synthesize textureCache;
@synthesize programCache;

+ (COpenGLAssetLibrary *)sharedInstance;
    {
    // TODO at some point this will be a singleton - maybe - but not today.
    // (We really need one per OGL context anyway singleton = bad here)
    return([[self alloc] init]);
    }

- (id)init
	{
	if ((self = [super init]) != NULL)
		{
        vertexBufferCache = [[NSCache alloc] init];
        textureCache = [[NSCache alloc] init];
        programCache = [[NSCache alloc] init];
		}
	return(self);
	}

- (CVertexBuffer *)vertexBufferForName:(NSString *)inName target:(GLenum)inTarget usage:(GLenum)inUsage
    {
    CVertexBuffer *theObject = [self.vertexBufferCache objectForKey:inName];
    if (theObject == NULL)
        {
        NSURL *theVBOURL = [[NSBundle mainBundle] URLForResource:[inName stringByDeletingPathExtension] withExtension:[inName pathExtension]];
        NSData *theVBOData = [NSData dataWithContentsOfURL:theVBOURL options:0 error:NULL];
        theObject = [[CVertexBuffer alloc] initWithTarget:inTarget usage:inUsage data:theVBOData];
        
        [self.vertexBufferCache setObject:theObject forKey:inName cost:theVBOData.length];
        }
    
    return(theObject);
    }

- (CProgram *)programForName:(NSString *)inName attributeNames:(NSArray *)inAttributeNames uniformNames:(NSArray *)inUniformNames error:(NSError **)outError;
    {
    #pragma unused (outError)
    
    CProgram *theProgram = [self.programCache objectForKey:inName];
    if (theProgram == NULL)
        {
        theProgram = [[CProgram alloc] initWithName:inName attributeNames:inAttributeNames uniformNames:inUniformNames];
        [self.programCache setObject:theProgram forKey:inName];
        }
    return(theProgram);
    }

@end

#pragma mark -

#if TARGET_OS_IPHONE

@implementation EAGLContext (EAGLContext_LibraryExtensions)

- (COpenGLAssetLibrary *)library   
    {
    static void *theKey = "EAGLContext_LibraryExtensions_Library";
    COpenGLAssetLibrary *theLibrary = objc_getAssociatedObject(self, theKey);
    if (theLibrary == NULL)
        {
        theLibrary = [[COpenGLAssetLibrary alloc] init];
        objc_setAssociatedObject(self, theKey, theLibrary, OBJC_ASSOCIATION_RETAIN);
        }
    return(theLibrary);    
    }

@end

#endif /* #if TARGET_OS_IPHONE */
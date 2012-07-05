//
//  CAssetLibrary.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 2/29/12.
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

#import "CAssetLibrary.h"

#import <objc/runtime.h>

#import "CTexture.h"
#import "CProgram.h"
#import "CShader.h"

#if TARGET_OS_IPHONE == 1
#import "PVRTexture.h"
#endif /* TARGET_OS_IPHONE == 1 */

@interface CAssetLibrary ()
@property (readwrite, nonatomic, weak) COpenGLContext *context;
@property (readwrite, nonatomic, strong) NSCache *cache;

- (NSURL *)URLForFileNamed:(NSString *)inName possiblePathExtensions:(NSArray *)inPossiblePathExtensions;
@end

#pragma mark -

@implementation CAssetLibrary

@synthesize context = _context;
@synthesize searchDirectoryURLs = _searchDirectoryURLs;
@synthesize cache = _cache;

- (id)initWithContext:(COpenGLContext *)inContext
    {
    if ((self = [super init]) != NULL)
        {
		_context = inContext;
		_searchDirectoryURLs = @[
			[NSBundle mainBundle].resourceURL,
			[[NSBundle mainBundle].resourceURL URLByAppendingPathComponent:@"Shaders"],
			];
		_cache = [[NSCache alloc] init];
        }
    return self;
    }

- (void)flushCache;
	{
	self.cache = [[NSCache alloc] init];
	}

- (CTexture *)textureNamed:(NSString *)inName error:(NSError **)outError
	{
	return([self textureNamed:inName cache:YES error:outError]);
	}
	
- (CTexture *)textureNamed:(NSString *)inName cache:(BOOL)inCache error:(NSError **)outError;
	{
	id theKey = [NSDictionary dictionaryWithObject:[inName stringByDeletingPathExtension] forKey:@"texture"];

	CTexture *theTexture = [self.cache objectForKey:theKey];
	if (theTexture == NULL)
		{
		#if TARGET_OS_IPHONE == 1
		NSArray *theFileExtensions = @[:@"pvrt", @"pvr", @"png", @"jpg", @"tiff"];
		#else
		NSArray *theFileExtensions = @[@"png", @"jpg", @"tiff"];
		#endif
		
		if (inName.pathExtension.length > 0)
			{
			theFileExtensions = [NSArray arrayWithObject:inName.pathExtension];
			inName = [inName stringByDeletingPathExtension];
			}
		
		NSURL *theURL = [self URLForFileNamed:inName possiblePathExtensions:theFileExtensions];
		
		if (theURL == NULL)
			{
			return(NULL);
			}
		
		if ([[theURL pathExtension] isEqualToString:@"pvrt"] || [[theURL pathExtension] isEqualToString:@"pvr"])
			{
			#if TARGET_OS_IPHONE == 1
			theTexture = [PVRTexture textureWithContentsOfURL:theURL error:outError];
			#endif
			}
		else
			{
			theTexture = [CTexture textureWithContentsOfURL:theURL error:outError];
			}
			
		theTexture.label = [theURL lastPathComponent];

		if (inCache == YES)
			{
			[self.cache setObject:theTexture forKey:theKey cost:theTexture.cost];
			}
		}
	return(theTexture);	
	}
	
- (CShader *)shaderNamed:(NSString *)inName error:(NSError **)outError;
	{
#if TOUCH_OPENGL_GL == 1
    inName = [NSString stringWithFormat:@"%@.GL.%@", [inName stringByDeletingPathExtension], [inName pathExtension]];
#elif TOUCH_OPENGL_GLES == 1
    inName = [NSString stringWithFormat:@"%@.GLES.%@", [inName stringByDeletingPathExtension], [inName pathExtension]];
#endif

	NSURL *theURL = [self URLForFileNamed:inName];
	CShader *theShader = [[CShader alloc] initWithURL:theURL error:outError];
	return(theShader);
	}

#pragma mark -

- (NSURL *)URLForFileNamed:(NSString *)inName
	{
	__block BOOL theStopFlag = NO;
	__block NSURL *theURL = NULL;

	[self.searchDirectoryURLs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

		NSURL *theDirectoryURL = obj;

		NSURL *thePotentialURL = [theDirectoryURL URLByAppendingPathComponent:inName];

		if ([thePotentialURL checkResourceIsReachableAndReturnError:NULL] == YES)
			{
			theURL = thePotentialURL;
			theStopFlag = YES;
			}

		*stop = theStopFlag;
		}];

	return(theURL);
	}

- (NSURL *)URLForFileNamed:(NSString *)inName possiblePathExtensions:(NSArray *)inPossiblePathExtensions
	{
	__block BOOL theStopFlag = NO;
	__block NSURL *theURL = NULL;

	[self.searchDirectoryURLs enumerateObjectsUsingBlock:^(id obj1, NSUInteger idx1, BOOL *stop1) {

		NSURL *theDirectoryURL = obj1;

		[inPossiblePathExtensions enumerateObjectsUsingBlock:^(id obj2, NSUInteger idx2, BOOL *stop2) {

			NSString *thePotentialFileName = [inName stringByAppendingPathExtension:obj2];

			NSURL *thePotentialURL = [theDirectoryURL URLByAppendingPathComponent:thePotentialFileName];
			
			if ([thePotentialURL checkResourceIsReachableAndReturnError:NULL] == YES)
				{
				theURL = thePotentialURL;
				theStopFlag = YES;
				}


			*stop2 = theStopFlag;
			}];

		*stop1 = theStopFlag;
		}];

	return(theURL);
	}

@end

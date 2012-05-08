//
//  CAssetLibrary.m
//  VideoFilterToy
//
//  Created by Jonathan Wight on 2/29/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "CAssetLibrary.h"

#import <objc/runtime.h>

#import "CTexture_Utilities.h"
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
	id theKey = @{ @"texture": [inName stringByDeletingPathExtension] };

	CTexture *theTexture = [self.cache objectForKey:theKey];
	if (theTexture == NULL)
		{
		#if TARGET_OS_IPHONE == 1
		NSArray *theFileExtensions = @[ @"pvrt", @"pvr", @"png", @"jpg", @"tiff" ];
		#else
		NSArray *theFileExtensions = @[ @"png", @"jpg", @"tiff" ];
		#endif
		
		if (inName.pathExtension.length > 0)
			{
			theFileExtensions = @[ inName.pathExtension ];
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

	[self.searchDirectoryURLs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

		NSURL *theDirectoryURL = obj;

		[inPossiblePathExtensions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

			NSString *thePotentialFileName = [inName stringByAppendingPathExtension:obj];

			NSURL *thePotentialURL = [theDirectoryURL URLByAppendingPathComponent:thePotentialFileName];
			
			if ([thePotentialURL checkResourceIsReachableAndReturnError:NULL] == YES)
				{
				theURL = thePotentialURL;
				theStopFlag = YES;
				}


			*stop = theStopFlag;
			}];

		*stop = theStopFlag;
		}];

	return(theURL);
	}

@end

#pragma mark -

@implementation COpenGLContext (COpenGLContext_AssetLibraryExtension)

static void *kKey;

- (CAssetLibrary *)assetLibrary
	{
	CAssetLibrary *theAssetLibrary = objc_getAssociatedObject(self, &kKey);
	if (theAssetLibrary == NULL)
		{
		theAssetLibrary = [[CAssetLibrary alloc] initWithContext:self];
		objc_setAssociatedObject(self, &kKey, theAssetLibrary, OBJC_ASSOCIATION_RETAIN);
		}
	return(theAssetLibrary);
	}

@end

//
//  COpenGLAsset.h
//  GLCameraTest
//
//  Created by Jonathan Wight on 2/21/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "COpenGLAsset.h"

#import "OpenGLIncludes.h"
#import "OpenGLTypes.h"

@implementation COpenGLAsset

@synthesize name = _name;

+ (GLenum)type
	{
	return(0);
	}

- (id)initWithName:(GLuint)inName
    {
    if ((self = [super init]) != NULL)
        {
        _name = inName;
        }


	if ([[self class] debug] == YES)
		{
		[[self class] trackAsset:self];
		}

    return self;
    }

- (void)dealloc
    {
	[self invalidate];
    }

- (NSString *)description
    {
    return([NSString stringWithFormat:@"%@ (label: \"%@\", cost: %d)", [super description], self.label, self.cost]);
    }


- (void)invalidate
	{
	if ([[self class] debug] == YES)
		{
		[[self class] untrackAsset:self];
		}

	_name = 0;
	}

- (NSString *)objectLabel
	{
	GLsizei theLength = 0;
	glGetObjectLabelEXT([[self class] type], self.name, 0, &theLength, NULL);
	char theBuffer[theLength + 1];
	glGetObjectLabelEXT([[self class] type], self.name, theLength + 1, &theLength, theBuffer);
	AssertOpenGLNoError_();
	NSString *theString = [NSString stringWithUTF8String:theBuffer];
	return(theString);
	}

- (void)setLabel:(NSString *)inLabel
	{
	_label = inLabel;
	// TODO -- need to figure this out. Cannot set labels on framebuffers.
	if (NO)
		{
		const char *theUTF8Label = [inLabel UTF8String];
		glLabelObjectEXT([[self class] type], self.name, strlen(theUTF8Label), theUTF8Label);
		AssertOpenGLNoError_();
		}
	}

- (GLuint)cost
	{
	return(0);
	}

//	glPushGroupMarkerEXT(<#GLsizei length#>, <#const GLchar *marker#>)

@end

#pragma mark -

@implementation COpenGLAsset (Debugging)

+ (BOOL)debug
	{
	return(NO);
	}

static NSMutableSet *trackedAssets = NULL;

+ (void)trackAsset:(COpenGLAsset *)inAsset
	{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		trackedAssets = [NSMutableSet set];
		});

	NSLog(@"TRACK %@ (%d)", inAsset, inAsset.cost);
	[trackedAssets addObject:inAsset];
	
	}

+ (void)untrackAsset:(COpenGLAsset *)inAsset
	{
	if ([trackedAssets containsObject:inAsset])
		{
		NSLog(@"UNTRACK %@ (%d)", inAsset, inAsset.cost);
		[trackedAssets removeObject:inAsset];
		}
	}

+ (void)clearTrackedAssets
	{
	trackedAssets = [NSMutableSet set];
	}
	
+ (void)dumpActiveAssets
	{
	for (COpenGLAsset *theAsset in trackedAssets)
		{
		NSLog(@"IN MEMORY: %@", theAsset);
		}
	}

@end



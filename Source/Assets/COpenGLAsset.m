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

@interface COpenGLAsset ()
@property (readwrite, nonatomic, assign) GLuint name;
@end

@implementation COpenGLAsset

@synthesize name = _name;
@synthesize label = _label;

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
    NSMutableArray *theComponents = [NSMutableArray array];
    if (self.label != NULL)
        {
        [theComponents addObject:[NSString stringWithFormat:@"label: %@", self.label]];
        }
    if (self.cost > 0)
        {
        [theComponents addObject:[NSString stringWithFormat:@"cost: %d", self.cost]];
        }

    return([NSString stringWithFormat:@"%@ (%@)", [super description], [theComponents componentsJoinedByString:@", "]]);
    }

- (void)invalidate
	{
	if ([[self class] debug] == YES)
		{
		[[self class] untrackAsset:self];
		}

	_name = 0;
	}
	
- (void)setName:(GLuint)name
	{
	if (_name != name)
		{
		[self invalidate];
		
		_name = name;
		}
	}

- (BOOL)named
	{
	return(_name != 0);
	}

- (NSString *)objectLabel
	{
	NSString *theString = NULL;
	#if TARGET_OS_IPHONE == 1
	GLsizei theLength = 0;
	glGetObjectLabelEXT([[self class] type], self.name, 0, &theLength, NULL);
	char theBuffer[theLength + 1];
	glGetObjectLabelEXT([[self class] type], self.name, theLength + 1, &theLength, theBuffer);
	AssertOpenGLNoError_();
	theString = [NSString stringWithUTF8String:theBuffer];
	#endif /* TARGET_OS_IPHONE == 1 */
	return(theString);
	}

- (void)setLabel:(NSString *)inLabel
	{
	_label = inLabel;
	// TODO -- need to figure this out. Cannot set labels on framebuffers.
	if (NO)
		{
	#if TARGET_OS_IPHONE == 1
		const char *theUTF8Label = [inLabel UTF8String];
		glLabelObjectEXT([[self class] type], self.name, strlen(theUTF8Label), theUTF8Label);
		AssertOpenGLNoError_();
	#endif /* TARGET_OS_IPHONE == 1 */
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



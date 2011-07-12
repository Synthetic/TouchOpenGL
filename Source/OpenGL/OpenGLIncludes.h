//
//  OpenGLIncludes.h
//  TouchOpenGL
//
//  Created by Jonathan Wight on 1/1/2000.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

#if TARGET_OS_IPHONE == 1
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <QuartzCore/QuartzCore.h>
#else
#import <OpenGL/OpenGL.h>
#include <OpenGL/glext.h>
#endif

//
//  OpenGLDebugging.h
//  GLCameraTest
//
//  Created by Jonathan Wight on 2/21/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#include <stdio.h>

#define GLLog_ GLLog

extern void GLLog(NSString *inFormat, ...);
extern void GLLogC(char const *inFormat);


//
//  OpenGLDebugging.m
//  GLCameraTest
//
//  Created by Jonathan Wight on 2/21/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

void GLLog(NSString *inFormat, ...)
	{
	va_list theArgList;

	va_start(theArgList, inFormat); 

	NSString *theString = [[NSString alloc] initWithFormat:inFormat arguments:theArgList];

	va_end(theArgList);

	GLLogC([theString UTF8String]);
	}

void GLLogC(char const *inFormat)
	{
	fprintf(stderr, "GL: %s\n", inFormat);
	}
	

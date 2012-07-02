//
//  OpenGLTypes.h
//  TouchOpenGL
//
//  Created by Jonathan Wight on 1/1/2000.
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

#import "OpenGLIncludes.h"

#import "Vector.h"
#import "Matrix.h"
#import "Quaternion.h"

typedef struct SIntPoint {
    GLint x, y;
    } SIntPoint;

typedef struct SIntSize {
    GLint width, height;
    } SIntSize;

typedef struct SIntPoint3 {
    GLint x, y, z;
    } SIntPoint3;

typedef struct SIntSize3 {
    GLint width, height, depth;
    } SIntSize3;

// TODO -- inline these suckers.

extern GLfloat DegreesToRadians(GLfloat inDegrees);
extern GLfloat RadiansToDegrees(GLfloat inDegrees);

#define D2R(v) DegreesToRadians((v))
#define R2D(v) RadiansToDegrees((v))

extern GLenum GLenumFromString(NSString *inString);
extern NSString *NSStringFromGLenum(GLenum inEnum);

#if DEBUG == 1

#define AssertOpenGLNoError_() do { GLint theError_ = glGetError(); if (theError_ != GL_NO_ERROR) NSLog(@"glGetError() returned %@ (0x%X)", NSStringFromGLenum(theError_), theError_); NSAssert1(theError_ == GL_NO_ERROR, @"Code entered with existing OGL error 0x%X", theError_); } while(0)

#if TARGET_OS_IPHONE == 1

#define AssertOpenGLValidContext_() NSAssert([EAGLContext currentContext] != NULL, @"No current context")

#else

#define AssertOpenGLValidContext_() NSAssert(CGLGetCurrentContext() != NULL, @"No current context")

#endif /* TARGET_OS_IPHONE == 1 */

#else

#define AssertOpenGLNoError_()
#define AssertOpenGLValidContext_()

#endif /* DEBUG == 1 */

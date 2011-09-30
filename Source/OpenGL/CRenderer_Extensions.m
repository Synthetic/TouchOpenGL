//
//  CRenderer_Extensions.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 03/17/11.
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

#import "CRenderer_Extensions.h"

#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

#import "CProgram.h"
#import "Color_OpenGLExtensions.h"
#import "COpenGLAssetLibrary.h"

@implementation CRenderer (CRenderer_Extensions)

- (COpenGLAssetLibrary *)library
    {
    #if TARGET_OS_IPHONE
    return([EAGLContext currentContext].library);
    #else
    
    static char kKey[] = "[CRenderer library]";
    
    COpenGLAssetLibrary *theLibrary = objc_getAssociatedObject(self, &kKey);
    if (theLibrary == NULL)
        {
        theLibrary = [[[COpenGLAssetLibrary  alloc] init] autorelease];
        objc_setAssociatedObject(self, &kKey, theLibrary, OBJC_ASSOCIATION_RETAIN);
        }
    return(theLibrary);
    #endif
    }

- (void)drawAxes:(Matrix4)inModelTransform
    {
    AssertOpenGLNoError_();

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);

    NSError *theError = NULL;
    CProgram *theProgram = [self.library programForName:@"Flat" attributeNames:[NSArray arrayWithObjects:@"a_position", @"a_color", NULL] uniformNames:[NSArray arrayWithObjects:@"u_modelViewMatrix", @"u_projectionMatrix", NULL] error:&theError];
    if (theProgram == NULL)
        {
        NSLog(@"Error: %@", theError);
        return;
        }

    const GLfloat kLength = 10000.0;

    Vector3 theVertices[] = {
        { .x = +kLength, .y = 0, .z = 0 },
        { .x = -kLength, .y = 0, .z = 0 },
        { .x = 0.0, .y = kLength, .z = 0 },
        { .x = 0.0, .y = -kLength, .z = 0 },
        { .x = 0.0, .y = 0, .z = kLength },
        { .x = 0.0, .y = 0, .z = -kLength },
        };

    Color4ub theColors[] = { 
        { 0xFF, 0, 0, 0xFF, },
        { 0xFF, 0, 0, 0xFF, },
        { 0, 0xFF, 0, 0xFF, },
        { 0, 0xFF, 0, 0xFF, },
        { 0, 0, 0xFF, 0xFF, },
        { 0, 0, 0xFF, 0xFF, },
        };

    // Use shader program
    [theProgram use];
    
    // Update position attribute
    GLuint theVertexAttributeIndex = [theProgram attributeIndexForName:@"a_position"];        
    glVertexAttribPointer(theVertexAttributeIndex, 3, GL_FLOAT, GL_FALSE, 0, theVertices);
    glEnableVertexAttribArray(theVertexAttributeIndex);

    AssertOpenGLNoError_();

    // Update color attribute
    GLuint theColorsAttributeIndex = [theProgram attributeIndexForName:@"a_color"];        
    glEnableVertexAttribArray(theColorsAttributeIndex);
    glVertexAttribPointer(theColorsAttributeIndex, 4, GL_UNSIGNED_BYTE, GL_TRUE, 0, theColors);

    AssertOpenGLNoError_();

    // Update transform uniform
    GLuint theModelViewMatrixUniform = [theProgram uniformIndexForName:@"u_modelViewMatrix"];
    glUniformMatrix4fv(theModelViewMatrixUniform, 1, NO, &inModelTransform.m[0][0]);

    GLuint theProjectionMatrixUniform = [theProgram uniformIndexForName:@"u_projectionMatrix"];
    Matrix4 theProjectionMatrix = self.projectionTransform;
    glUniformMatrix4fv(theProjectionMatrixUniform, 1, NO, &theProjectionMatrix.m[0][0]);


    // Validate program before drawing. This is a good check, but only really necessary in a debug build. DEBUG macro must be defined in your debug configurations if that's not already the case.
#if defined(DEBUG)
    if ([theProgram validate:&theError] == NO)
        {
        NSLog(@"Failed to validate program: %@", theError);
        return;
        }
#endif

    AssertOpenGLNoError_();

    glLineWidth(1);

    glDrawArrays(GL_LINES, 0, 6);

    AssertOpenGLNoError_();
    }

- (void)drawBoundingBox:(Matrix4)inModelTransform v1:(Vector3)v1 v2:(Vector3)v2;
    {
    AssertOpenGLNoError_();

//    inModelTransform = Matrix4Identity;

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);

    NSError *theError = NULL;
    CProgram *theProgram = [self.library programForName:@"Flat" attributeNames:[NSArray arrayWithObjects:@"a_position", @"a_color", NULL] uniformNames:[NSArray arrayWithObjects:@"u_modelViewMatrix", @"u_projectionMatrix", NULL] error:&theError];
    if (theProgram == NULL)
        {
        NSLog(@"Error: %@", theError);
        return;
        }

    // TODO should just have a static unit cube and then scale it with a matrix...
    Vector3 theVertices[] = {
        { .x = v1.x, .y = v1.y, .z = v1.z }, { .x = v2.x, .y = v1.y, .z = v1.z },
        { .x = v1.x, .y = v2.y, .z = v1.z }, { .x = v2.x, .y = v2.y, .z = v1.z },
        { .x = v1.x, .y = v1.y, .z = v1.z }, { .x = v1.x, .y = v2.y, .z = v1.z },
        { .x = v2.x, .y = v1.y, .z = v1.z }, { .x = v2.x, .y = v2.y, .z = v1.z },

        { .x = v1.x, .y = v1.y, .z = v2.z }, { .x = v2.x, .y = v1.y, .z = v2.z },
        { .x = v1.x, .y = v2.y, .z = v2.z }, { .x = v2.x, .y = v2.y, .z = v2.z },
        { .x = v1.x, .y = v1.y, .z = v2.z }, { .x = v1.x, .y = v2.y, .z = v2.z },
        { .x = v2.x, .y = v1.y, .z = v2.z }, { .x = v2.x, .y = v2.y, .z = v2.z },

        { .x = v1.x, .y = v1.y, .z = v1.z }, { .x = v1.x, .y = v1.y, .z = v2.z },
        { .x = v2.x, .y = v1.y, .z = v1.z }, { .x = v2.x, .y = v1.y, .z = v2.z },

        { .x = v1.x, .y = v2.y, .z = v1.z }, { .x = v1.x, .y = v2.y, .z = v2.z },
        { .x = v2.x, .y = v2.y, .z = v1.z }, { .x = v2.x, .y = v2.y, .z = v2.z },

        };

    // TODO - can't get glVertexAttrib4f to work.
    Color4ub theColors[] = { 
        { 0xFF, 0xFF, 0xFF, 0xFF, },
        { 0xFF, 0xFF, 0xFF, 0xFF, },
        { 0xFF, 0xFF, 0xFF, 0xFF, },
        { 0xFF, 0xFF, 0xFF, 0xFF, },
        { 0xFF, 0xFF, 0xFF, 0xFF, },
        { 0xFF, 0xFF, 0xFF, 0xFF, },
        { 0xFF, 0xFF, 0xFF, 0xFF, },
        { 0xFF, 0xFF, 0xFF, 0xFF, },
        { 0xFF, 0xFF, 0xFF, 0xFF, },
        { 0xFF, 0xFF, 0xFF, 0xFF, },
        { 0xFF, 0xFF, 0xFF, 0xFF, },
        { 0xFF, 0xFF, 0xFF, 0xFF, },
        { 0xFF, 0xFF, 0xFF, 0xFF, },
        { 0xFF, 0xFF, 0xFF, 0xFF, },
        { 0xFF, 0xFF, 0xFF, 0xFF, },
        { 0xFF, 0xFF, 0xFF, 0xFF, },
        { 0xFF, 0xFF, 0xFF, 0xFF, },
        { 0xFF, 0xFF, 0xFF, 0xFF, },
        { 0xFF, 0xFF, 0xFF, 0xFF, },
        { 0xFF, 0xFF, 0xFF, 0xFF, },
        { 0xFF, 0xFF, 0xFF, 0xFF, },
        { 0xFF, 0xFF, 0xFF, 0xFF, },
        { 0xFF, 0xFF, 0xFF, 0xFF, },
        { 0xFF, 0xFF, 0xFF, 0xFF, },
        };

    // Use shader program
    [theProgram use];
    
    // Update position attribute
    GLuint theVertexAttributeIndex = [theProgram attributeIndexForName:@"a_position"];        
    glVertexAttribPointer(theVertexAttributeIndex, 3, GL_FLOAT, GL_FALSE, 0, theVertices);
    glEnableVertexAttribArray(theVertexAttributeIndex);

    AssertOpenGLNoError_();

    // Update color attribute
    GLuint theColorsAttributeIndex = [theProgram attributeIndexForName:@"a_color"];        
    glEnableVertexAttribArray(theColorsAttributeIndex);
    glVertexAttribPointer(theColorsAttributeIndex, 4, GL_UNSIGNED_BYTE, GL_TRUE, 0, theColors);
//    glVertexAttrib4f(theColorsAttributeIndex, 1.0, 1.0, 1.0, 1.0);

    AssertOpenGLNoError_();


    // Update transform uniform
    GLuint theModelViewMatrixUniform = [theProgram uniformIndexForName:@"u_modelViewMatrix"];
    glUniformMatrix4fv(theModelViewMatrixUniform, 1, NO, &inModelTransform.m[0][0]);

    GLuint theProjectionMatrixUniform = [theProgram uniformIndexForName:@"u_projectionMatrix"];
    Matrix4 theProjectionMatrix = self.projectionTransform;
    glUniformMatrix4fv(theProjectionMatrixUniform, 1, NO, &theProjectionMatrix.m[0][0]);


    // Validate program before drawing. This is a good check, but only really necessary in a debug build. DEBUG macro must be defined in your debug configurations if that's not already the case.
#if defined(DEBUG)
    if ([theProgram validate:&theError] == NO)
        {
        NSLog(@"Failed to validate program: %@", theError);
        return;
        }
#endif

    AssertOpenGLNoError_();

    glLineWidth(1);

    glDrawArrays(GL_LINES, 0, sizeof(theVertices) / sizeof(theVertices[0]));

    AssertOpenGLNoError_();
    }

- (void)drawBackgroundGradient
{
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);

    NSError *theError = NULL;
    CProgram *theProgram = [self.library programForName:@"Gradient" attributeNames:[NSArray arrayWithObjects:@"a_position", NULL] uniformNames:[NSArray arrayWithObjects:@"u_projectionMatrix", NULL] error:&theError];
    if (theProgram == NULL)
        {
        NSLog(@"Error: %@", theError);
        return;
        }

    const float kFarClippingPlane = -8.0f;
    const float kGlowRadius = 15.0f;
    Vector3 theVertices[] = {
        { .x = -kGlowRadius, .y = -kGlowRadius, .z = kFarClippingPlane },
        { .x = kGlowRadius, .y = -kGlowRadius, .z = kFarClippingPlane },
        { .x = kGlowRadius, .y = kGlowRadius, .z = kFarClippingPlane },
        { .x = -kGlowRadius, .y = kGlowRadius, .z = kFarClippingPlane }
    };

    // Use shader program
    [theProgram use];

    // Update position attribute
    GLuint theVertexAttributeIndex = [theProgram attributeIndexForName:@"a_position"];
    glVertexAttribPointer(theVertexAttributeIndex, 3, GL_FLOAT, GL_FALSE, 0, theVertices);
    glEnableVertexAttribArray(theVertexAttributeIndex);

    GLuint theProjectionMatrixUniform = [theProgram uniformIndexForName:@"u_projectionMatrix"];
    Matrix4 theProjectionMatrix = self.projectionTransform;
    glUniformMatrix4fv(theProjectionMatrixUniform, 1, NO, &theProjectionMatrix.m[0][0]);

    glDrawArrays(GL_TRIANGLE_FAN, 0, sizeof(theVertices) / sizeof(theVertices[0]));
}

@end

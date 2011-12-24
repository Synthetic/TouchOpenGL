//
//  CSketchCanvas.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 02/15/11.
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

#import "CSketchCanvas.h"

#import "CProgram.h"

#import "CShader.h"
#import "CImageRenderer.h"
#import "CVertexBuffer.h"
#import "UIColor_OpenGLExtensions.h"
#import "CVertexBufferReference.h"
#import "CVertexBufferReference_FactoryExtensions.h"

@interface CSketchCanvas ()
@property (readwrite, nonatomic, retain) CProgram *program;
@property (readwrite, nonatomic, retain) CVertexBuffer *geometryCoordinates;
@property (readwrite, nonatomic, retain) CVertexBufferReference *geometryCoordinatesReference;
@end

#pragma mark -

@implementation CSketchCanvas

@synthesize size;
@synthesize imageRenderer;

@synthesize program;
@synthesize geometryCoordinates;
@synthesize geometryCoordinatesReference;

- (id)init
	{
	if ((self = [super init]) != NULL)
		{
        size = (CGSize){ 512, 512 }; 
        
        imageRenderer = [[CImageRenderer alloc] initWithSize:(SIntSize){ 512, 512 }];

        NSArray *theShaders = [NSArray arrayWithObjects:   
            [[CShader alloc] initWithName:@"Brush.fsh"],
            [[CShader alloc] initWithName:@"Brush.vsh"],
            NULL];
        
        program = [[CProgram alloc] initWithFiles:theShaders];

        NSError *theError = NULL;
        if ([self.program validate:&theError] == NO)
            {
            NSLog(@"Failed to validate program: %@", theError);
            }
        
        // Geometry Vertices
        const CGFloat F = 0.05;
        
//        self.geometryCoordinates = [CVertexBuffer vertexBufferWithRect:(CGRect){ -1.0 * F, -1.0 * F, 2.0 * F, 2.0 * F }];
        self.geometryCoordinates = [CVertexBuffer vertexBufferWithCircleWithRadius:F points:32];
        self.geometryCoordinatesReference = [[CVertexBufferReference alloc] initWithVertexBuffer:self.geometryCoordinates cellEncoding:@encode(Vector2) normalized:NO stride:0];
		}
	return(self);
	}

- (void)drawAtPoint:(CGPoint)inPoint
    {
    self.imageRenderer.renderBlock = ^(Matrix4 inTransform) {

        GLuint theVertexAttributeIndex = [self.program attributeIndexForName:@"vertex"];
        GLuint theColorUniformIndex = [self.program uniformIndexForName:@"u_color"];
//        GLuint thePointUniformIndex = [self.program uniformIndexForName:@"u_center"];
        GLuint theTransformUniformIndex = [self.program uniformIndexForName:@"u_transform"];
    
        AssertOpenGLNoError_();

        // Use shader program
        glUseProgram(self.program.name);

        // Update attribute values
        glBindBuffer(GL_ARRAY_BUFFER, self.geometryCoordinatesReference.vertexBuffer.name);
        glVertexAttribPointer(theVertexAttributeIndex, self.geometryCoordinatesReference.size, self.geometryCoordinatesReference.type, self.geometryCoordinatesReference.normalized, self.geometryCoordinatesReference.stride, 0);
        glEnableVertexAttribArray(theVertexAttributeIndex);

        // Update transform
        Vector4 thePoint = (Vector4){
            .x = inPoint.x / 512 * 2.0 - 1.0,
            .y = inPoint.y / 512 * 2.0 - 1.0,
            };
        inTransform = Matrix4Identity;        
        inTransform = Matrix4Translate(inTransform, thePoint.x, -thePoint.y, 0);
        glUniformMatrix4fv(theTransformUniformIndex, 1, NO, &inTransform.m00);

        // Update uniform values
        Color4f theColor = [UIColor blackColor].color4f;
        glUniform4fv(theColorUniformIndex, 1, &theColor.r);

        // Update point
//        glUniform4fv(thePointUniformIndex, 1, &thePoint.x);

        // Validate program before drawing. This is a good check, but only really necessary in a debug build. DEBUG macro must be defined in your debug configurations if that's not already the case.

#if defined(DEBUG)
        NSError *theError = NULL;
        if ([self.program validate:&theError] == NO)
            {
            NSLog(@"Failed to validate program: %@", theError);
            return;
            }
#endif

        // Draw
        glDrawArrays(GL_TRIANGLE_FAN, 0, self.geometryCoordinatesReference.cellCount);


        // Update uniform values
        
        theColor = [UIColor blackColor].color4f;
        glUniform4fv(theColorUniformIndex, 1, &theColor.r);

        glDrawArrays(GL_LINE_STRIP, 0, self.geometryCoordinatesReference.cellCount);


        };
    [self.imageRenderer render];

    }

@end

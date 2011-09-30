//
//  CTestSceneRenderer.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 03/09/11.
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

#import "CTestSceneRenderer.h"

#import "CScene.h"
#import "CSceneGeometry.h"
#import "CSceneStyle.h"
#import "CProgram_ConvenienceExtensions.h"
#import "CVertexBufferReference.h"
#import "OpenGLTypes.h"
#import "CVertexBuffer.h"
#import "CSceneGeometryBrush.h"
#import "CVertexBuffer_FactoryExtensions.h"
#import "UIColor_OpenGLExtensions.h"

@implementation CTestSceneRenderer

- (id)init
    {
    if ((self = [super init]) != NULL)
        {
        CScene *theScene = [[[CScene alloc] init] autorelease];
                
        CVertexBuffer *theCoordinatesVertexBuffer = [CVertexBuffer vertexBufferWithRect:(CGRect){ -0.5, -0.5, 1, 1 }];
        CVertexBuffer *theColorsVertexBuffer = [CVertexBuffer vertexBufferWithColors:[NSArray arrayWithObjects:[UIColor redColor], [UIColor redColor], [UIColor redColor], [UIColor redColor], NULL]];

        CSceneGeometry *theGeometry = [[[CSceneGeometry alloc] init] autorelease];
        theGeometry.coordinatesBufferReference = [[[CVertexBufferReference alloc] initWithVertexBuffer:theCoordinatesVertexBuffer cellEncoding:@encode(Vector2) normalized:GL_FALSE] autorelease];
        theGeometry.colorsBufferReference = [[[CVertexBufferReference alloc] initWithVertexBuffer:theColorsVertexBuffer cellEncoding:@encode(Color4f) normalized:GL_TRUE] autorelease];
        theGeometry.vertexBuffers = [NSSet setWithObjects:theCoordinatesVertexBuffer, theColorsVertexBuffer, NULL];

        CSceneStyle *theStyle = [[[CSceneStyle alloc] init] autorelease];
        theStyle.mask = SceneStyleMask_ProgramFlag | SceneStyleMask_ColorFlag;
        theGeometry.style = theStyle;

        CProgram *theFlatProgram = [[[CProgram alloc] initWithFilename:@"Flat" attributeNames:[NSArray arrayWithObjects:@"vertex", @"color", @"texture", NULL] uniformNames:NULL] autorelease];
        theStyle.program = theFlatProgram;
        
        theStyle.color = [[UIColor redColor] color4f];
        
        CSceneGeometryBrush *theBrush = [[[CSceneGeometryBrush alloc] init] autorelease];
        theBrush.type = GL_TRIANGLE_STRIP;
        theBrush.geometry = theGeometry;
        
        [theGeometry addSubnode:theBrush];
        
        [theScene addSubnode:theGeometry];

        [theScene dump];
        
        self.sceneGraph = theScene;
        }
    return(self);
    }


@end

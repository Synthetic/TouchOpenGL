//
//  CTestSceneRenderer.m
//  OpenGLTest
//
//  Created by Jonathan Wight on 9/10/11.
//  Copyright (c) 2011 toxicsoftware.com. All rights reserved.
//

#import "CTestSceneRenderer.h"

#import "CVertexBuffer.h"
#import "CVertexBuffer_FactoryExtensions.h"
#import "CVertexBufferReference.h"
#import "CProgram.h"
#import "CFlatProgram.h"
#import "CSceneRenderer_Extensions.h"
#import "COpenGLAssetLibrary.h"
#import "CProgram_Extensions.h"
#import "CMutableVertexBuffer.h"

#define RANDOM() ((float)arc4random() / (float)UINT32_MAX)

@interface CTestSceneRenderer ()
@property (readwrite, nonatomic, retain) CFlatProgram *program;
@property (readwrite, nonatomic, retain) CMutableVertexBuffer *colorBuffer;
@end

#pragma mark -

@implementation CTestSceneRenderer

@synthesize program;
@synthesize colorBuffer;

- (void)setup;
    {
    [super setup];

    AssertOpenGLValidContext_();

    NSURL *theURL = [[NSBundle mainBundle].resourceURL URLByAppendingPathComponent:@"Shaders/Flat.program.plist"];
    self.program = [[CFlatProgram alloc] initWithURL:theURL];
    NSParameterAssert(self.program);

    // ####################################################  #####################

    CVertexBuffer *thePositionsBuffer = [CVertexBuffer vertexBufferWithRect:(CGRect){ -0.5, -0.25, 1, 0.5 }];
    CVertexBufferReference *thePositionsReference = [[CVertexBufferReference alloc] initWithVertexBuffer:thePositionsBuffer cellEncoding:@encode(Vector3) normalized:NO];

    self.program.positions = thePositionsReference;

    // #########################################################################

    self.colorBuffer = [CMutableVertexBuffer vertexBufferWithColors:[NSArray arrayWithObjects:
        [UIColor colorWithHue:RANDOM() saturation:1.0 brightness:1.0 alpha:1.0],
        [UIColor colorWithHue:RANDOM() saturation:1.0 brightness:1.0 alpha:1.0],
        [UIColor colorWithHue:RANDOM() saturation:1.0 brightness:1.0 alpha:1.0],
        [UIColor colorWithHue:RANDOM() saturation:1.0 brightness:1.0 alpha:1.0],
        NULL]];
    CVertexBufferReference *theColorsReference = [[CVertexBufferReference alloc] initWithVertexBuffer:self.colorBuffer cellEncoding:@encode(Color4ub) normalized:YES];
    self.program.colors = theColorsReference;
    }

- (void)render
    {
    NSMutableData *theData = self.colorBuffer.mutableData;
    Color4ub *theColors = [theData mutableBytes];
    for (int N = 0; N != 4; ++N)
        {
        theColors[N].r = RANDOM() * 0xFF;
        theColors[N].g = RANDOM() * 0xFF;
        theColors[N].b = RANDOM() * 0xFF;
        }
    [self.colorBuffer update];
    
    [self.program use];

    AssertOpenGLNoError_();

    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    AssertOpenGLNoError_();
    }



@end

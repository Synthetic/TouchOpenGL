//
//  CTestSceneRenderer.m
//  OpenGLTest
//
//  Created by Jonathan Wight on 9/10/11.
//  Copyright (c) 2011 toxicsoftware.com. All rights reserved.
//

#import "CTestSceneRenderer.h"

#import "CVertexBuffer.h"
#import "CVertexBufferReference_FactoryExtensions.h"
#import "CVertexBufferReference.h"
#import "CProgram.h"
#import "CFlat.h"
#import "CSceneRenderer_Extensions.h"
#import "COpenGLAssetLibrary.h"
#import "CProgram_Extensions.h"
#import "CMutableVertexBuffer.h"
#import "UIColor_OpenGLExtensions.h"

#define RANDOM() ((float)arc4random() / (float)UINT32_MAX)

@interface CTestSceneRenderer ()
@property (readwrite, nonatomic, retain) CFlat *program;
@end

#pragma mark -

@implementation CTestSceneRenderer

@synthesize program;

- (void)setup;
    {
    [super setup];

    AssertOpenGLValidContext_();

    NSURL *theURL = [[NSBundle mainBundle].resourceURL URLByAppendingPathComponent:@"Shaders/Flat.program.plist"];
    self.program = [[CFlat alloc] initWithURL:theURL];
    NSParameterAssert(self.program);

    // ####################################################  #####################

    CVertexBufferReference *thePositionsReference = [CVertexBufferReference vertexBufferReferenceWithRect:(CGRect){ -0.5, -0.25, 1, 0.5 }];

    self.program.positions = thePositionsReference;
    }

- (void)render
    {
    [self.program use];
    
    self.program.color = [UIColor colorWithHue:RANDOM() saturation:1.0 brightness:1.0 alpha:1.0].color4f;

    AssertOpenGLNoError_();

    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    AssertOpenGLNoError_();
    }



@end

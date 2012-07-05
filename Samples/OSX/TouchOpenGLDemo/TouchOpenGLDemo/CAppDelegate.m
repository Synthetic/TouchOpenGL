//
//  CAppDelegate.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 6/23/12.
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

#import "CAppDelegate.h"

#import "COpenGLRendererView.h"
#import "CSceneRendererView.h"
#import "CTextureRenderer.h"
#import "COffscreenOpenGLContext.h"
#import "COpenGLContext+Debugging.h"
#import "CTexture.h"
#import "CBlockRenderer.h"
#import "COpenGLContext+Drawing.h"
#import "NSColor_OpenGLExtensions.h"

@interface CAppDelegate ()
@property (readwrite, nonatomic, assign) IBOutlet COpenGLRendererView *rendererView;
@end

#pragma mark -

@implementation CAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
    {
    CTextureRenderer *theTextureRenderer = [[CTextureRenderer alloc] init];
    theTextureRenderer.textureBlock = ^(void) {
        CTexture *theTexture = [CTexture textureNamed:@"lena_std.tiff" error:NULL];
        return(theTexture);
        };

//    CBlockRenderer *theBlockRenderer = [[CBlockRenderer alloc] init];
//    theBlockRenderer.renderBlock = ^(void) {
//        [theBlockRenderer.context strokeRect:(CGRect){ .size = { 20, 20 } } color:[NSColor redColor].color4f];
//        };

#if 1
    [self.rendererView addRenderer:theTextureRenderer];
//    [self.rendererView addRenderer:theBlockRenderer];
#else
    COffscreenOpenGLContext *theContext = [[COffscreenOpenGLContext alloc] initWithSize:(SIntSize){ 1024, 1024 }];
    [theContext dump];
    [theContext render:theRenderer];

    CTexture *theTexture = [theContext readTextureSize:theContext.size];

    [theTexture writeToFile:@"/Users/schwa/Desktop/test.png"];
    [theContext dump];
#endif
    }

@end

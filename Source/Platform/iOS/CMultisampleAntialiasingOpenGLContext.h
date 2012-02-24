//
//  CMultisampleAntialiasingOpenGLContext.h
//  VideoFilterToy
//
//  Created by Jonathan Wight on 2/23/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "COpenGLContext.h"

@class CFrameBuffer;
@class CRenderBuffer;

@interface CMultisampleAntialiasingOpenGLContext : COpenGLContext

@property (readonly, nonatomic, strong) CFrameBuffer *multisampleFrameBuffer;
@property (readonly, nonatomic, strong) CRenderBuffer *multisampleDepthBuffer;
@property (readonly, nonatomic, strong) CRenderBuffer *multisampleColorBuffer;

@end

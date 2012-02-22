//
//  CTexture_Utilities.h
//  GLCameraTest
//
//  Created by Jonathan Wight on 2/20/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "CTexture.h"

@interface CTexture (CTexture_Utilities)

+ (id)textureWithCGImage:(CGImageRef)inImage size:(SIntSize)inSize format:(GLint)inFormat type:(GLint)inType error:(NSError **)outError;
+ (id)textureWithCGImage:(CGImageRef)inImage error:(NSError **)outError;

- (CGImageRef)fetchImageViaFrameBuffer CF_RETURNS_RETAINED;
- (CGImageRef)fetchImage CF_RETURNS_RETAINED;

- (void)writeToFile:(NSString *)inPath;

@end

//
//  CTexture_Utilities.h
//  GLCameraTest
//
//  Created by Jonathan Wight on 2/20/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

#import "CTexture.h"

@interface CTexture (CTexture_Utilities)

- (CGImageRef)fetchImage CF_RETURNS_RETAINED;
- (void)writeToFile:(NSString *)inPath;

@end

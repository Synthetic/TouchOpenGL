//
//  CNewMesh.h
//  TouchOpenGL
//
//  Created by Jonathan Wight on 03/22/11.
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

#import <Foundation/Foundation.h>

#import "OpenGLTypes.h"
#import "Matrix.h"

@interface CMesh : NSObject <NSCopying> {
    
}

@property (readonly, nonatomic, strong) NSArray *geometries;
@property (readonly, nonatomic, assign) Vector3 center; // in model space
@property (readonly, nonatomic, assign) Vector3 p1, p2; // in model space
@property (readonly, nonatomic, assign) Matrix4 transform;
@property (readonly, nonatomic, assign) BOOL cullBackFaces;
@property (readonly, nonatomic, strong) NSString *programName;

@end

#pragma mark -

@interface CMutableMesh : CMesh <NSMutableCopying> {
    
}

@property (readwrite, nonatomic, strong) NSArray *geometries;
@property (readwrite, nonatomic, assign) Vector3 center; // in model space
@property (readwrite, nonatomic, assign) Vector3 p1, p2; // in model space
@property (readwrite, nonatomic, assign) Matrix4 transform;
@property (readwrite, nonatomic, assign) BOOL cullBackFaces;
@property (readwrite, nonatomic, strong) NSString *programName;

@end

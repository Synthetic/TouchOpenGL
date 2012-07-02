//
//  CVertexBufferReference.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 01/31/11.
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

#import "CVertexBufferReference.h"

#import "CVertexBuffer.h"
#import "OpenGLTypes.h"

@interface CVertexBufferReference ()
@property (readwrite, nonatomic, strong) CVertexBuffer *vertexBuffer;

@property (readwrite, nonatomic, assign) GLint size;
@property (readwrite, nonatomic, assign) GLenum type;
@property (readwrite, nonatomic, assign) GLboolean normalized;
@property (readwrite, nonatomic, assign) GLsizei stride;
@property (readwrite, nonatomic, assign) GLsizei offset;

@property (readwrite, nonatomic, assign) GLint rowSize;
@property (readwrite, nonatomic, assign) GLint rowCount;

+ (BOOL)computeRowCount:(GLint *)outRowCount type:(GLenum *)outType size:(GLint *)outSize rowSize:(GLint *)outRowSize vertexBuffer:(CVertexBuffer *)inVertexBuffer fromEncoding:(const char *)inEncoding;
@end

#pragma mark -

@implementation CVertexBufferReference

@synthesize vertexBuffer;
@synthesize size;
@synthesize type;
@synthesize normalized;
@synthesize stride;
@synthesize offset;

@synthesize rowSize;
@synthesize rowCount;

- (id)initWithVertexBuffer:(CVertexBuffer *)inVertexBuffer rowSize:(GLint)inRowSize rowCount:(GLint)inRowCount size:(GLint)inSize type:(GLenum)inType normalized:(GLboolean)inNormalized stride:(GLsizei)inStride offset:(GLsizei)inOffset
    {
    if ((self = [super init]) != NULL)
        {
		NSAssert(inVertexBuffer != NULL, @"We need a vertex buffer.");
        NSAssert1(inSize >= 1 && inSize <= 4, @"Size (%d) needs to be between 1 & 4", inSize);
        NSAssert3((size_t)(inRowCount * inRowSize) == inVertexBuffer.data.length, @"Row size (%d) * row count (%d) != vertex buffer length (%d)", inRowSize, inRowCount, (int)inVertexBuffer.data.length);
        NSAssert(inStride == 0 || inStride <= inRowSize, @"Stride should be either 0 or row size");
        NSAssert(inOffset == 0 || inOffset < inStride, @"Offset should be 0 or less then stride");

        vertexBuffer = inVertexBuffer;

        rowSize = inRowSize;
        rowCount = inRowCount;
        size = inSize;
        type = inType;
        normalized = inNormalized;
        stride = inStride;
        offset = inOffset;
        }
    return(self);
    }
    
- (id)initWithVertexBuffer:(CVertexBuffer *)inVertexBuffer rowSize:(GLint)inRowSize rowCount:(GLint)inRowCount size:(GLint)inSize type:(GLenum)inType normalized:(GLboolean)inNormalized
    {
    if ((self = [self initWithVertexBuffer:inVertexBuffer rowSize:inRowSize rowCount:inRowCount size:inSize type:inType normalized:inNormalized stride:0 offset:0]) != NULL)
        {
        }
    return(self);
    }
    
- (NSString *)description
    {
    return([NSString stringWithFormat:@"%@ (VBO:%@, rowSize:%d, rowCount:%d, size:%d, type:%@, normalized:%d, stride:%d, offset:%d", [super description], self.vertexBuffer, self.rowSize, self.rowCount, self.size, NSStringFromGLenum(self.type), self.normalized, self.stride, self.offset]);
    }

#pragma mark -

- (void)bind
    {
    AssertOpenGLNoError_();

    glBindBuffer(self.vertexBuffer.target, self.vertexBuffer.name);

    AssertOpenGLNoError_();
    }
    
- (void)use:(GLuint)inAttributeIndex
    {
    AssertOpenGLNoError_();

    glBindBuffer(self.vertexBuffer.target, self.vertexBuffer.name);

    AssertOpenGLNoError_();

    glVertexAttribPointer(inAttributeIndex, self.size, self.type, self.normalized, self.stride, (const GLvoid *)self.offset);

    AssertOpenGLNoError_();
    }

#pragma mark -

- (id)initWithVertexBuffer:(CVertexBuffer *)inVertexBuffer cellEncoding:(char *)inEncoding normalized:(GLboolean)inNormalized stride:(GLsizei)inStride offset:(GLsizei)inOffset
    {
    GLint theRowSize = 0, theRowCount = 0, theSize;
    
    GLenum theType;
    
    
    [[self class] computeRowCount:&theRowCount type:&theType size:&theSize rowSize:&theRowSize vertexBuffer:inVertexBuffer fromEncoding:inEncoding];
    
    if ((self = [self initWithVertexBuffer:inVertexBuffer rowSize:theRowSize rowCount:theRowCount size:theSize type:theType normalized:inNormalized stride:inStride offset:inOffset]) != NULL)
        {
        }
    return(self);
    }
    
- (id)initWithVertexBuffer:(CVertexBuffer *)inVertexBuffer cellEncoding:(char *)inEncoding normalized:(GLboolean)inNormalized;
    {
    if ((self = [self initWithVertexBuffer:inVertexBuffer cellEncoding:inEncoding normalized:inNormalized stride:0 offset:0]) != NULL)
        {
        }
    return(self);
    }

+ (BOOL)computeRowCount:(GLint *)outRowCount type:(GLenum *)outType size:(GLint *)outSize rowSize:(GLint *)outRowSize vertexBuffer:(CVertexBuffer *)inVertexBuffer fromEncoding:(const char *)inEncoding
    {
    NSUInteger theRowSize = 0;
    NSGetSizeAndAlignment(inEncoding, &theRowSize, NULL);
    *outRowSize = (GLint)theRowSize;
    
    *outRowCount = (GLint)([inVertexBuffer.data length] / theRowSize);

    NSString *theCellEncodingString = [NSString stringWithUTF8String:inEncoding];

    NSScanner *theScanner = [NSScanner scannerWithString:theCellEncodingString];
    theScanner.charactersToBeSkipped = NULL;
    theScanner.caseSensitive = YES;

    NSString *theMemberTypes = NULL;
    
    BOOL theResult = [theScanner scanString:@"{" intoString:NULL];
    if (theResult == YES)
        {
        NSAssert(theResult == YES, @"Scan failed");
        NSString *theTypeName = NULL;
        theResult = [theScanner scanCharactersFromSet:[NSCharacterSet alphanumericCharacterSet] intoString:&theTypeName];
        NSAssert(theResult == YES, @"Scan failed");
        theResult = [theScanner scanString:@"=" intoString:NULL];
        NSAssert(theResult == YES, @"Scan failed");

        theResult = [theScanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"fdcCsSiI"] intoString:&theMemberTypes];
        NSAssert(theResult == YES, @"Scan failed");

        theResult = [theScanner scanString:@"}" intoString:NULL];
        NSAssert(theResult == YES, @"Scan failed");

        *outSize = (GLint)[theMemberTypes length];
        }
    else
        {
        theResult = [theScanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"fdcCsSiI"] intoString:&theMemberTypes];
        NSAssert(theResult == YES, @"Scan failed");

        *outSize = 1;
        }


    // TODO we're assuming all types are the same (e.g. ffff vs fdfd). This is probably a safe assumption but we should assert on bad data anyways.
    if ([theMemberTypes characterAtIndex:0] == 'f')
        {
        *outType = GL_FLOAT;
        }
    else if ([theMemberTypes characterAtIndex:0] == 'd')
        {
        #if TARGET_OS_IPHONE == 1
        NSAssert(NO, @"No GL_DOUBLE");
        #else
        *outType = GL_DOUBLE;
        #endif
        }
    else if ([theMemberTypes characterAtIndex:0] == 'c')
        {
        *outType = GL_BYTE;
        }
    else if ([theMemberTypes characterAtIndex:0] == 'C')
        {
        *outType = GL_UNSIGNED_BYTE;
        }
    else if ([theMemberTypes characterAtIndex:0] == 's')
        {
        *outType = GL_SHORT;
        }
    else if ([theMemberTypes characterAtIndex:0] == 'S')
        {
        *outType = GL_UNSIGNED_SHORT;
        }
    else if ([theMemberTypes characterAtIndex:0] == 'i')
        {
        *outType = GL_INT;
        }
    else if ([theMemberTypes characterAtIndex:0] == 'I')
        {
        *outType = GL_UNSIGNED_INT;
        }
    else
        {
        NSAssert(NO, @"Scan failed");
        }
        
    NSAssert(*outType != 0, @"Type shoudl not be zero.");
    
    return(YES);
    }

@end

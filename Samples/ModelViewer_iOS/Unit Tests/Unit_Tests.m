//
//  Unit_Tests.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 03/25/11.
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

#import "Unit_Tests.h"

#import "OpenGLTypes.h"

@implementation Unit_Tests

//- (void)setUp
//    {
//    [super setUp];
//    }
//
//- (void)tearDown
//    {
//    [super tearDown];
//    }

#pragma mark -

- (void)testDegreesToRadians
    {
    STAssertEqualsWithAccuracy(DegreesToRadians(45.0), (GLfloat)0.785398163397448, 0.0000001, @"");
    }

- (void)testRadiansToDegrees
    {
    STAssertEqualsWithAccuracy(RadiansToDegrees(0.785398163397448), (GLfloat)45.0, 0.0000001, @"");
    }

- (void)testDegreesToRadiansToDegrees
    {
    STAssertEqualsWithAccuracy(RadiansToDegrees(DegreesToRadians(45.0)), (GLfloat)45.0, 0.0000001, @"");
    }

#pragma mark -

- (void)testVector3Length
    {
    Vector3 theVector = { 1.1, 22.2, 333.3 };
    GLfloat theExpectedResult = 334.0403269067973;
    GLfloat theGivenResult = Vector3Length(theVector);
    STAssertEqualsWithAccuracy(theExpectedResult, theGivenResult, 0.0, @"");
    }

@end

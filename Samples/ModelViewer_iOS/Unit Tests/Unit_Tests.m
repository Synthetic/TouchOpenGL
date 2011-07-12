//
//  Unit_Tests.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 03/25/11.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//

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

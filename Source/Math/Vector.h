//
//  Vector.h
//  TouchOpenGLDemo
//
//  Created by Jonathan Wight on 7/2/12.
//  Copyright (c) 2012 Jonathan Wight. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <GLKit/GLKit.h>

#import "OpenGLIncludes.h"

typedef struct Vector3ub {
    struct { GLubyte x, y, z; };
    struct { GLubyte r, g, b; };
    struct { GLubyte s, t, p; };
    GLubyte v[3];
    } Vector3ub;

typedef struct Vector4ub {
    struct { GLubyte x, y, z, w; };
    struct { GLubyte r, g, b, a; };
    struct { GLubyte s, t, p, q; };
    GLubyte v[4];
    } Vector4ub;

#pragma mark -

typedef GLKVector2 Vector2f;
typedef GLKVector3 Vector3f;
typedef GLKVector4 Vector4f;

#pragma mark -

typedef Vector3ub Color3ub;

typedef Vector3f Color3f;

typedef Vector4ub Color4ub;

typedef Vector4f Color4f;

#pragma mark -

extern GLfloat Vector3fLength(Vector3f inVector);
extern Vector3f Vector3fCrossProduct(Vector3f inLHS, Vector3f inRHS);
extern GLfloat Vector3fDotProduct(Vector3f inLHS, Vector3f inRHS);
extern Vector3f Vector3fNormalize(Vector3f inVector);
extern Vector3f Vector3fAdd(Vector3f inLHS, Vector3f inRHS);
extern Vector3f Vector3fFromVector4f(Vector4f inVector);

extern NSString *NSStringFromVector3f(Vector3f inVector);
extern NSString *NSStringFromVector4f(Vector4f inVector);

extern NSString *NSStringFromColor4f(Color4f inColor);

extern Color4f Color4fFromPropertyListRepresentation(id inPropertyListRepresentation);

extern Vector3f Vector3fFromPropertyListRepresentation(id inPropertyListRepresentation);

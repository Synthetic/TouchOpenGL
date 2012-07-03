//
//  Vector.h
//  TouchOpenGLDemo
//
//  Created by Jonathan Wight on 7/2/12.
//  Copyright (c) 2012 Jonathan Wight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenGLIncludes.h"

typedef struct Vector2 {
    struct { GLfloat x, y; };
    struct { GLfloat s, t; };
    GLfloat v[2];
    } Vector2;

typedef struct Vector3 {
    struct { GLfloat x, y, z; };
    struct { GLfloat r, g, b; };
    struct { GLfloat s, t, p; };
    GLfloat v[3];
    } Vector3;

typedef struct Vector4 {
    struct { GLfloat x, y, z, w; };
    struct { GLfloat r, g, b, a; };
    struct { GLfloat s, t, p, q; };
    GLfloat v[4];
    } Vector4;

typedef struct Color4ub {
    GLubyte r,g,b,a;
    } Color4ub;

typedef struct Color4f {
    GLfloat r,g,b,a;
    } Color4f;

typedef struct Color3ub {
    GLubyte r,g,b;
    } Color3ub;

typedef struct Color3f {
    GLfloat r,g,b;
    } Color3f;

extern GLfloat Vector3Length(Vector3 inVector);
extern Vector3 Vector3CrossProduct(Vector3 inLHS, Vector3 inRHS);
extern GLfloat Vector3DotProduct(Vector3 inLHS, Vector3 inRHS);
extern Vector3 Vector3Normalize(Vector3 inVector);
extern Vector3 Vector3Add(Vector3 inLHS, Vector3 inRHS);
extern Vector3 Vector3FromVector4(Vector4 inVector);

extern NSString *NSStringFromVector3(Vector3 inVector);
extern NSString *NSStringFromVector4(Vector4 inVector);

extern NSString *NSStringFromColor4f(Color4f inColor);


extern Color4f Color4fFromPropertyListRepresentation(id inPropertyListRepresentation);

extern Vector3 Vector3FromPropertyListRepresentation(id inPropertyListRepresentation);

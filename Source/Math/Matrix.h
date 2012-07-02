//
//  OpenGLTypes.h
//  TouchOpenGL
//
//  Created by Jonathan Wight on 9/7/2010.
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


#import "OpenGLIncludes.h"

typedef struct Matrix4 {
    GLfloat mm[4][4];
} Matrix4;

typedef struct Matrix3 {
    GLfloat mm[3][3];
} Matrix3;

extern const Matrix4 Matrix4Identity;

extern BOOL Matrix4IsIdentity(Matrix4 t);
extern BOOL Matrix4EqualToTransform(Matrix4 a, Matrix4 b);
extern Matrix4 Matrix4MakeTranslation(GLfloat tx, GLfloat ty, GLfloat tz);
extern Matrix4 Matrix4MakeScale(GLfloat sx, GLfloat sy, GLfloat sz);
extern Matrix4 Matrix4MakeRotation(GLfloat angle, GLfloat x, GLfloat y, GLfloat z);
extern Matrix4 Matrix4Translate(Matrix4 t, GLfloat tx, GLfloat ty, GLfloat tz);
extern Matrix4 Matrix4Scale(Matrix4 t, GLfloat sx, GLfloat sy, GLfloat sz);
extern Matrix4 Matrix4Rotate(Matrix4 t, GLfloat angle, GLfloat x, GLfloat y, GLfloat z);
extern Matrix4 Matrix4Concat(Matrix4 a, Matrix4 b);
extern Matrix4 Matrix4Invert(Matrix4 t);
extern Matrix4 Matrix4Transpose(Matrix4 t);
extern NSString *NSStringFromMatrix4(Matrix4 t);

extern Matrix4 Matrix4FromPropertyListRepresentation(id inPropertyListRepresentation);

extern Matrix4 Matrix4Perspective(GLfloat fovy, GLfloat aspect, GLfloat zNear, GLfloat zFar);
extern Matrix4 Matrix4Ortho(float left, float right, float bottom, float top, float nearZ, float farZ);

extern NSValue *NSValueWithMatrix4(Matrix4 inM4);
Matrix4 Matrix4WithNSValue(NSValue *inValue);

extern CGAffineTransform CGAffineTransformFromMatrix4(Matrix4 inMatrix);

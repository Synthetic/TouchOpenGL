//
//  Matrix.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 1/1/2000.
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

#import "Matrix.h"

#include <tgmath.h>

#import "OpenGLTypes.h"

#include <tgmath.h>

// Matrix4f code based on code from http://sunflow.sourceforge.net/

const Matrix4f Matrix4Identity = {
    .mm = {
        { 1.0, 0.0, 0.0, 0.0 },
        { 0.0, 1.0, 0.0, 0.0 },
        { 0.0, 0.0, 1.0, 0.0 },
        { 0.0, 0.0, 0.0, 1.0 },
        }
    };

BOOL Matrix4IsIdentity(Matrix4f t)
    {
    return(Matrix4EqualToTransform(t, Matrix4Identity));
    }

BOOL Matrix4EqualToTransform(Matrix4f a, Matrix4f b)
    {
    return(memcmp(&a, &b, sizeof(Matrix4f)) == 0);
    }
    
Matrix4f Matrix4MakeTranslation(GLfloat tx, GLfloat ty, GLfloat tz)
    {
    const Matrix4f theMatrix = {
        .mm = {
            { 1.0, 0.0, 0.0, 0.0 },
            { 0.0, 1.0, 0.0, 0.0 },
            { 0.0, 0.0, 1.0, 0.0 },
            { tx,  ty,  tz,  1.0 },
            }
        };
    return(theMatrix);
    }
    
Matrix4f Matrix4MakeScale(GLfloat sx, GLfloat sy, GLfloat sz)
    {
    const Matrix4f theMatrix = {
        .mm = {
            { sx, 0.0, 0.0, 0.0 },
            { 0.0, sy, 0.0, 0.0 },
            { 0.0, 0.0, sz, 0.0 },
            { 0.0, 0.0, 0.0, 1.0 },
            }
        };
    return(theMatrix);
    }
    
Matrix4f Matrix4MakeRotation(GLfloat angle, GLfloat x, GLfloat y, GLfloat z)
    {
    Matrix4f m = {};
    const GLfloat invLen = 1.0f / sqrt(x * x + y * y + z * z);
    x *= invLen;
    y *= invLen;
    z *= invLen;
    const GLfloat s = sin(angle);
    const GLfloat c = cos(angle);
    const GLfloat t = 1.0f - c;
    m.mm[0][0] = t * x * x + c;
    m.mm[1][1] = t * y * y + c;
    m.mm[2][2] = t * z * z + c;
    const GLfloat txy = t * x * y;
    const GLfloat sz = s * z;
    m.mm[0][1] = txy - sz;
    m.mm[1][0] = txy + sz;
    const GLfloat txz = t * x * z;
    const GLfloat sy = s * y;
    m.mm[0][2] = txz + sy;
    m.mm[2][0] = txz - sy;
    const GLfloat tyz = t * y * z;
    const GLfloat sx = s * x;
    m.mm[1][2] = tyz - sx;
    m.mm[2][1] = tyz + sx;
    m.mm[3][3] = 1.0;
    return m;
    }
    
Matrix4f Matrix4Translate(Matrix4f t, GLfloat tx, GLfloat ty, GLfloat tz)
    {
    return(Matrix4Concat(t, Matrix4MakeTranslation(tx, ty, tz)));
    }
    
Matrix4f Matrix4Scale(Matrix4f t, GLfloat sx, GLfloat sy, GLfloat sz)
    {
    return(Matrix4Concat(t, Matrix4MakeScale(sx, sy, sz)));
    }
    
Matrix4f Matrix4Rotate(Matrix4f t, GLfloat angle, GLfloat x, GLfloat y, GLfloat z)
    {
    return(Matrix4Concat(t, Matrix4MakeRotation(angle, x, y, z)));
    }
    
Matrix4f Matrix4Concat(Matrix4f LHS, Matrix4f RHS)
    {
    Matrix4f theMatrix = { 
        .mm = {
            {
            LHS.mm[0][0] * RHS.mm[0][0] + LHS.mm[0][1] * RHS.mm[1][0] + LHS.mm[0][2] * RHS.mm[2][0] + LHS.mm[0][3] * RHS.mm[3][0],
            LHS.mm[0][0] * RHS.mm[0][1] + LHS.mm[0][1] * RHS.mm[1][1] + LHS.mm[0][2] * RHS.mm[2][1] + LHS.mm[0][3] * RHS.mm[3][1],
            LHS.mm[0][0] * RHS.mm[0][2] + LHS.mm[0][1] * RHS.mm[1][2] + LHS.mm[0][2] * RHS.mm[2][2] + LHS.mm[0][3] * RHS.mm[3][2],
            LHS.mm[0][0] * RHS.mm[0][3] + LHS.mm[0][1] * RHS.mm[1][3] + LHS.mm[0][2] * RHS.mm[2][3] + LHS.mm[0][3] * RHS.mm[3][3],
            },
            {
            LHS.mm[1][0] * RHS.mm[0][0] + LHS.mm[1][1] * RHS.mm[1][0] + LHS.mm[1][2] * RHS.mm[2][0] + LHS.mm[1][3] * RHS.mm[3][0],
            LHS.mm[1][0] * RHS.mm[0][1] + LHS.mm[1][1] * RHS.mm[1][1] + LHS.mm[1][2] * RHS.mm[2][1] + LHS.mm[1][3] * RHS.mm[3][1],
            LHS.mm[1][0] * RHS.mm[0][2] + LHS.mm[1][1] * RHS.mm[1][2] + LHS.mm[1][2] * RHS.mm[2][2] + LHS.mm[1][3] * RHS.mm[3][2],
            LHS.mm[1][0] * RHS.mm[0][3] + LHS.mm[1][1] * RHS.mm[1][3] + LHS.mm[1][2] * RHS.mm[2][3] + LHS.mm[1][3] * RHS.mm[3][3],
            },
            {
            LHS.mm[2][0] * RHS.mm[0][0] + LHS.mm[2][1] * RHS.mm[1][0] + LHS.mm[2][2] * RHS.mm[2][0] + LHS.mm[2][3] * RHS.mm[3][0],
            LHS.mm[2][0] * RHS.mm[0][1] + LHS.mm[2][1] * RHS.mm[1][1] + LHS.mm[2][2] * RHS.mm[2][1] + LHS.mm[2][3] * RHS.mm[3][1],
            LHS.mm[2][0] * RHS.mm[0][2] + LHS.mm[2][1] * RHS.mm[1][2] + LHS.mm[2][2] * RHS.mm[2][2] + LHS.mm[2][3] * RHS.mm[3][2],
            LHS.mm[2][0] * RHS.mm[0][3] + LHS.mm[2][1] * RHS.mm[1][3] + LHS.mm[2][2] * RHS.mm[2][3] + LHS.mm[2][3] * RHS.mm[3][3],
            },
            {
            LHS.mm[3][0] * RHS.mm[0][0] + LHS.mm[3][1] * RHS.mm[1][0] + LHS.mm[3][2] * RHS.mm[2][0] + LHS.mm[3][3] * RHS.mm[3][0],
            LHS.mm[3][0] * RHS.mm[0][1] + LHS.mm[3][1] * RHS.mm[1][1] + LHS.mm[3][2] * RHS.mm[2][1] + LHS.mm[3][3] * RHS.mm[3][1],
            LHS.mm[3][0] * RHS.mm[0][2] + LHS.mm[3][1] * RHS.mm[1][2] + LHS.mm[3][2] * RHS.mm[2][2] + LHS.mm[3][3] * RHS.mm[3][2],
            LHS.mm[3][0] * RHS.mm[0][3] + LHS.mm[3][1] * RHS.mm[1][3] + LHS.mm[3][2] * RHS.mm[2][3] + LHS.mm[3][3] * RHS.mm[3][3],
            },
        }
    };
    return(theMatrix);
    }

//static void __gluMultMatricesf(const GLfloat a[16], const GLfloat b[16],
//                               GLfloat r[16])
//{
//    int i, j;
//
//    for (i = 0; i < 4; i++)
//    {
//        for (j = 0; j < 4; j++)
//        {
//            r[i*4+j] = a[i*4+0]*b[0*4+j] +
//                       a[i*4+1]*b[1*4+j] +
//                       a[i*4+2]*b[2*4+j] +
//                       a[i*4+3]*b[3*4+j];
//        }
//    }
//}
//
//
//Matrix4f Matrix4Concat(Matrix4f LHS, Matrix4f RHS)
//    {
//    Matrix4f theMatrix;
//    __gluMultMatricesf(&LHS.mm[0][0], &RHS.mm[0][0], &theMatrix.mm[0][0]);
//    return(theMatrix);
//    }




    
Matrix4f Matrix4Invert(Matrix4f t)
    {
    const GLfloat A0 = t.mm[0][0] * t.mm[1][1] - t.mm[0][1] * t.mm[1][0];
    const GLfloat A1 = t.mm[0][0] * t.mm[1][2] - t.mm[0][2] * t.mm[1][0];
    const GLfloat A2 = t.mm[0][0] * t.mm[1][3] - t.mm[0][3] * t.mm[1][0];
    const GLfloat A3 = t.mm[0][1] * t.mm[1][2] - t.mm[0][2] * t.mm[1][1];
    const GLfloat A4 = t.mm[0][1] * t.mm[1][3] - t.mm[0][3] * t.mm[1][1];
    const GLfloat A5 = t.mm[0][2] * t.mm[1][3] - t.mm[0][3] * t.mm[1][2];

    const GLfloat B0 = t.mm[2][0] * t.mm[3][1] - t.mm[2][1] * t.mm[3][0];
    const GLfloat B1 = t.mm[2][0] * t.mm[3][2] - t.mm[2][2] * t.mm[3][0];
    const GLfloat B2 = t.mm[2][0] * t.mm[3][3] - t.mm[2][3] * t.mm[3][0];
    const GLfloat B3 = t.mm[2][1] * t.mm[3][2] - t.mm[2][2] * t.mm[3][1];
    const GLfloat B4 = t.mm[2][1] * t.mm[3][3] - t.mm[2][3] * t.mm[3][1];
    const GLfloat B5 = t.mm[2][2] * t.mm[3][3] - t.mm[2][3] * t.mm[3][2];

    const GLfloat det = A0 * B5 - A1 * B4 + A2 * B3 + A3 * B2 - A4 * B1 + A5 * B0;
    NSCAssert(fabs(det) >= 1e-12f, @"Not invertable");
    const GLfloat invDet = 1.0 / det;
    Matrix4f m = {
        .mm = {
            {
            (+t.mm[1][1] * B5 - t.mm[1][2] * B4 + t.mm[1][3] * B3) * invDet,
            (-t.mm[1][0] * B5 + t.mm[1][2] * B2 - t.mm[1][3] * B1) * invDet,
            (+t.mm[1][0] * B4 - t.mm[1][1] * B2 + t.mm[1][3] * B0) * invDet,
            (-t.mm[1][0] * B3 + t.mm[1][1] * B1 - t.mm[1][2] * B0) * invDet,
            },
            {
            (-t.mm[0][1] * B5 + t.mm[0][2] * B4 - t.mm[0][3] * B3) * invDet,
            (+t.mm[0][0] * B5 - t.mm[0][2] * B2 + t.mm[0][3] * B1) * invDet,
            (-t.mm[0][0] * B4 + t.mm[0][1] * B2 - t.mm[0][3] * B0) * invDet,
            (+t.mm[0][0] * B3 - t.mm[0][1] * B1 + t.mm[0][2] * B0) * invDet,
            },
            {
            (+t.mm[3][1] * A5 - t.mm[3][2] * A4 + t.mm[3][3] * A3) * invDet,
            (-t.mm[3][0] * A5 + t.mm[3][2] * A2 - t.mm[3][3] * A1) * invDet,
            (+t.mm[3][0] * A4 - t.mm[3][1] * A2 + t.mm[3][3] * A0) * invDet,
            (-t.mm[3][0] * A3 + t.mm[3][1] * A1 - t.mm[3][2] * A0) * invDet,
            },
            {
            (-t.mm[2][1] * A5 + t.mm[2][2] * A4 - t.mm[2][3] * A3) * invDet,
            (+t.mm[2][0] * A5 - t.mm[2][2] * A2 + t.mm[2][3] * A1) * invDet,
            (-t.mm[2][0] * A4 + t.mm[2][1] * A2 - t.mm[2][3] * A0) * invDet,
            (+t.mm[2][0] * A3 - t.mm[2][1] * A1 + t.mm[2][2] * A0) * invDet,
            },
            }
        };
    return(m);
    }

Matrix4f Matrix4Transpose(Matrix4f t)
    {
    Matrix4f m;
    for (int X = 0; X != 4; ++X)
        {
        for (int Y = 0; Y != 4; ++Y)
            {
            m.mm[X][Y] = t.mm[Y][X];
            }
        }
    return(m);
    }
    
NSString *NSStringFromMatrix4(Matrix4f t)
    {
    return([NSString stringWithFormat:@"{ %g, %g, %g, %g,\n%g, %g, %g, %g,\n%g, %g, %g, %g,\n%g, %g, %g, %g }",
        t.mm[0][0], t.mm[0][1], t.mm[0][2], t.mm[0][3],
        t.mm[1][0], t.mm[1][1], t.mm[1][2], t.mm[1][3],
        t.mm[2][0], t.mm[2][1], t.mm[2][2], t.mm[2][3],
        t.mm[3][0], t.mm[3][1], t.mm[3][2], t.mm[3][3]]);
    }

Matrix4f Matrix4FromPropertyListRepresentation(id inPropertyListRepresentation)
	{
	Matrix4f theMatrix = Matrix4Identity;
	
	if ([inPropertyListRepresentation isKindOfClass:[NSString class]])
		{
		NSCAssert(NO, @"Can't build a matrix from a string.");
		}
	else if ([inPropertyListRepresentation isKindOfClass:[NSArray class]])
		{
		theMatrix.mm[0][0] = [[[inPropertyListRepresentation objectAtIndex:0] objectAtIndex:0] doubleValue];
		theMatrix.mm[0][1] = [[[inPropertyListRepresentation objectAtIndex:0] objectAtIndex:1] doubleValue];
		theMatrix.mm[0][2] = [[[inPropertyListRepresentation objectAtIndex:0] objectAtIndex:2] doubleValue];
		theMatrix.mm[0][3] = [[[inPropertyListRepresentation objectAtIndex:0] objectAtIndex:3] doubleValue];

		theMatrix.mm[1][0] = [[[inPropertyListRepresentation objectAtIndex:1] objectAtIndex:0] doubleValue];
		theMatrix.mm[1][1] = [[[inPropertyListRepresentation objectAtIndex:1] objectAtIndex:1] doubleValue];
		theMatrix.mm[1][2] = [[[inPropertyListRepresentation objectAtIndex:1] objectAtIndex:2] doubleValue];
		theMatrix.mm[1][3] = [[[inPropertyListRepresentation objectAtIndex:1] objectAtIndex:3] doubleValue];

		theMatrix.mm[2][0] = [[[inPropertyListRepresentation objectAtIndex:2] objectAtIndex:0] doubleValue];
		theMatrix.mm[2][1] = [[[inPropertyListRepresentation objectAtIndex:2] objectAtIndex:1] doubleValue];
		theMatrix.mm[2][2] = [[[inPropertyListRepresentation objectAtIndex:2] objectAtIndex:2] doubleValue];
		theMatrix.mm[2][3] = [[[inPropertyListRepresentation objectAtIndex:2] objectAtIndex:3] doubleValue];

		theMatrix.mm[3][0] = [[[inPropertyListRepresentation objectAtIndex:3] objectAtIndex:0] doubleValue];
		theMatrix.mm[3][1] = [[[inPropertyListRepresentation objectAtIndex:3] objectAtIndex:1] doubleValue];
		theMatrix.mm[3][2] = [[[inPropertyListRepresentation objectAtIndex:3] objectAtIndex:2] doubleValue];
		theMatrix.mm[3][3] = [[[inPropertyListRepresentation objectAtIndex:3] objectAtIndex:3] doubleValue];
		}

	return(theMatrix);
	}

#pragma mark -

//Matrix4f Matrix4Perspective(GLfloat fov, GLfloat aspect, GLfloat znear, GLfloat zfar)
// {
//  float ymax = znear * tan(fov * M_PI / 180.0);
//  float ymin = -ymax;
//  float xmax = ymax * aspect;
//  float xmin = ymin * aspect;
//
//  float width = fabs(xmax - xmin);
//  float height = fabs(ymax - ymin);
//
//  float depth = zfar - znear;
//  float q = -(zfar + znear) / depth;
//  float qn = -2 * (zfar * znear) / depth;
//
//  float w = 2 * znear / width;
//  w = w / aspect;
//  float h = 2 * znear / height;
//
//    Matrix4f theMatrix;
//
//    float *m = &theMatrix.mm[0][0];
//  m[0]  = w;
//  m[1]  = 0;
//  m[2]  = 0;
//  m[3]  = 0;
//
//  m[4]  = 0;
//  m[5]  = h;
//  m[6]  = 0;
//  m[7]  = 0;
//
//  m[8]  = 0;
//  m[9]  = 0;
//  m[10] = q;
//  m[11] = -1;
//
//  m[12] = 0;
//  m[13] = 0;
//  m[14] = qn;
//  m[15] = 0;
//  return(theMatrix);
// }


Matrix4f Matrix4Perspective(GLfloat fovy, GLfloat aspect, GLfloat zNear, GLfloat zFar)
    {
    Matrix4f m = Matrix4Identity;

    GLfloat sine, cotangent, deltaZ;
    GLfloat radians = fovy / 2 * M_PI / 180;

    deltaZ = zFar-zNear;
    sine = sin(radians);
    if ((deltaZ == 0) || (sine == 0) || (aspect == 0))
        {
        return(m);
        }
    cotangent = cos(radians) / sine;

    m.mm[0][0] = cotangent / aspect;
    m.mm[1][1] = cotangent;
    m.mm[2][2] = -(zFar + zNear) / deltaZ;
    m.mm[2][3] = -1;
    m.mm[3][2] = -2 * zNear * zFar / deltaZ;
    m.mm[3][3] = 0;
    return(m);
    }


Matrix4f Matrix4Ortho(float left, float right, float bottom, float top, float nearZ, float farZ)
    {
    float       deltaX = right - left;
    float       deltaY = top - bottom;
    float       deltaZ = farZ - nearZ;
    Matrix4f    ortho = Matrix4Identity;

    if ( (deltaX == 0.0f) || (deltaY == 0.0f) || (deltaZ == 0.0f) )
        return(ortho);

    ortho.mm[0][0] = 2.0f / deltaX;
    ortho.mm[3][0] = -(right + left) / deltaX;
    ortho.mm[1][1] = 2.0f / deltaY;
    ortho.mm[3][1] = -(top + bottom) / deltaY;
    ortho.mm[2][2] = -2.0f / deltaZ;
    ortho.mm[3][2] = -(nearZ + farZ) / deltaZ;

    
    return(ortho);
    }

#pragma mark -

NSValue *NSValueWithMatrix4(Matrix4f inM4)
    {
    return([NSValue valueWithBytes:&inM4 objCType:@encode(Matrix4f)]);
    }

Matrix4f Matrix4WithNSValue(NSValue *inValue)
    {
    Matrix4f theMatrix;
    [inValue getValue:&theMatrix];
    return(theMatrix);
    }

extern CGAffineTransform CGAffineTransformFromMatrix4(Matrix4f inMatrix)
    {
    CGAffineTransform theTransform = {
        .a = inMatrix.mm[0][0],
        .b = inMatrix.mm[1][0],
        .c = inMatrix.mm[0][1],
        .d = inMatrix.mm[1][1],
        .tx = inMatrix.mm[3][0],
        .ty = inMatrix.mm[3][1],
        };
    return(theTransform);
    }



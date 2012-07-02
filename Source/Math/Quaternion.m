//
//  Quaternion.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 03/10/11.
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

#include "Quaternion.h"

#include <tgmath.h>

#import "OpenGLIncludes.h"
#import "OpenGLTypes.h"
#import "Matrix.h"

// Based on http://code.google.com/p/libgdx/source/browse/trunk/gdx/src/com/badlogic/gdx/math/Quaternion.java

#define NORMALIZATION_TOLERANCE 0.00001f

Quaternion QuaternionIdentity = { .x = 0.0, .y = 0.0, .z = 0.0, .w = 1.0 };

Quaternion QuaternionNormalize(Quaternion q);

Quaternion QuaternionSetAxisAngle(Vector3 inAxis, GLfloat inAngle)
    {
    const GLfloat l_sin = sin(inAngle * 0.5);
    const GLfloat l_cos = cos(inAngle * 0.5);
    Quaternion theQuat = { .x = inAxis.x * l_sin, .y = inAxis.y * l_sin, .z = inAxis.z * l_sin, .w = l_cos };
    theQuat = QuaternionNormalize(theQuat);
    return(theQuat);
    }

GLfloat QuaternionLength2(Quaternion inQuat)
    {
    return(inQuat.x * inQuat.x + inQuat.y * inQuat.y + inQuat.z * inQuat.z + inQuat.w * inQuat.w);
    }

Quaternion QuaternionNormalize(Quaternion inQuat)
    {
    GLfloat len = QuaternionLength2(inQuat);
    if (len != 0.0f && fabs(len - 1.0f) > NORMALIZATION_TOLERANCE)
        {
        len = sqrt(len);
        inQuat.w /= len;
        inQuat.x /= len;
        inQuat.y /= len;
        inQuat.z /= len;
        }
    return(inQuat);
    }

Quaternion QuaternionSetEuler(GLfloat inYaw, GLfloat inPitch, GLfloat inRoll)
    {
    const GLfloat num9 = inRoll * 0.5f;
    const GLfloat num6 = sin(num9);
    const GLfloat num5 = cos(num9);
    const GLfloat num8 = inPitch * 0.5f;
    const GLfloat num4 = sin(num8);
    const GLfloat num3 = cos(num8);
    const GLfloat num7 = inYaw * 0.5f;
    const GLfloat num2 = sin(num7);
    const GLfloat num = cos(num7);
    const Quaternion q = {
        .x = ((num * num4) * num5) + ((num2 * num3) * num6),
        .y = ((num2 * num3) * num5) - ((num * num4) * num6),
        .z = ((num * num3) * num6) - ((num2 * num4) * num5),
        .w = ((num * num3) * num5) + ((num2 * num4) * num6),
        };
    return(q);
    }

void QuaternionGetEuler(Quaternion q, GLfloat *outYaw, GLfloat *outPitch, GLfloat *outRoll)
{
    const GLfloat qx = q.x;
    const GLfloat qy = q.y;
    const GLfloat qz = q.z;
    const GLfloat qw = q.w;
    const GLfloat qxqyPLUSqzqw = qx*qy + qz*qw;
    const GLfloat epsilon = 0.001f;
    if (qxqyPLUSqzqw > 0.5f - epsilon) {
        *outYaw = 2.0f * atan2(qx,qw);
        *outRoll = M_PI_2;
        *outPitch = 0.0f;
    } else if (qxqyPLUSqzqw < -0.5f + epsilon) {
        *outYaw = 2.0f * atan2(qx,qw);
        *outRoll = -M_PI_2;
        *outPitch = 0.0f;
    }
    *outYaw = atan2(2.0f*qy*qw - 2.0f*qx*qz, 1.0f - 2.0f*qy*qy - 2*qz*qz);
    *outRoll = asin(2.0f*qxqyPLUSqzqw);
    *outPitch = atan2(2.0f*qx*qw-2.0f*qy*qz , 1.0f - 2.0f*qx*qx - 2.0f*qz*qz);
}

Quaternion QuaternionConjugate(Quaternion q)
    {
    q.x *= -1;
    q.y *= -1;
    q.z *= -1;
    return(q);
    }

Quaternion QuaternionMultiply(Quaternion inLHS, Quaternion inRHS)
    {
    Quaternion theResult = {
        .x = inLHS.w * inRHS.x + inLHS.x * inRHS.w + inLHS.y * inRHS.z - inLHS.z * inRHS.y,
        .y = inLHS.w * inRHS.y + inLHS.y * inRHS.w + inLHS.z * inRHS.x - inLHS.x * inRHS.z,
        .z = inLHS.w * inRHS.z + inLHS.z * inRHS.w + inLHS.x * inRHS.y - inLHS.y * inRHS.x,
        .w = inLHS.w * inRHS.w - inLHS.x * inRHS.x - inLHS.y * inRHS.y - inLHS.z * inRHS.z,
        };
    return(theResult);
    }

Matrix4 Matrix4FromQuaternion(Quaternion q)
    {
    const GLfloat xx = q.x * q.x;
    const GLfloat xy = q.x * q.y;
    const GLfloat xz = q.x * q.z;
    const GLfloat xw = q.x * q.w;
    const GLfloat yy = q.y * q.y;
    const GLfloat yz = q.y * q.z;
    const GLfloat yw = q.y * q.w;
    const GLfloat zz = q.z * q.z;
    const GLfloat zw = q.z * q.w;

    Matrix4 theMatrix = {
        .mm[0][0] = 1.0 - 2.0 * (yy + zz),
        .mm[0][1] = 2.0 * (xy - zw),
        .mm[0][2] = 2.0 * (xz + yw),
        .mm[0][3] = 0.0,
        .mm[1][0] = 2.0 * (xy + zw),
        .mm[1][1] = 1.0 - 2.0 * (xx + zz),
        .mm[1][2] = 2.0 * (yz - xw),
        .mm[1][3] = 0.0,
        .mm[2][0] = 2.0 * (xz - yw),
        .mm[2][1] = 2.0 * (yz + xw),
        .mm[2][2] = 1.0 - 2.0 * (xx + yy),
        .mm[2][3] = 0.0,
        .mm[3][0] = 0.0,
        .mm[3][1] = 0.0,
        .mm[3][2] = 0.0,
        .mm[3][3] = 1.0,
        };
    return(theMatrix);
    }

extern NSString *NSStringFromQuaternion(Quaternion q)
    {
    return([NSString stringWithFormat:@"(%g, %g, %g, %g)", q.x, q.y, q.z, q.w]);
    }

extern Quaternion QuaternionConstrainedToAxis(Quaternion q, Vector3 axis)
{
    if ((axis.x == 0.0f && axis.y == 0.0f && axis.z == 0.0f) || (q.x == 0.0f && q.y == 0.0f && q.z == 0.0f)) {
        return q;
    }

    Vector3 curl;
    curl.x = q.x;
    curl.y = q.y;
    curl.z = q.z;
    curl = Vector3Normalize(curl);

    axis = Vector3Normalize(axis);
    GLfloat dot = Vector3DotProduct(axis, curl);
    Quaternion r;
    if (dot != 0.0f) {
        GLfloat angle = 2.0f * acosf(q.w);
        r = QuaternionSetAxisAngle(axis, dot * angle);
    } else {
        r = QuaternionIdentity;
    }

    return r;
}

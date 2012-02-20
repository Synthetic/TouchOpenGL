//
//  CNewModelLoader.m
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

#import "CMeshLoader.h"

#import "CMesh.h"
#import "CGeometry.h"
#import "CVertexBufferReference.h"
#import "CVertexBuffer_PropertyListRepresentation.h"
#import "NSData_NumberExtensions.h"
#import "CMaterial.h"
#import "CLazyTexture.h"

#define NO_DEFAULTS 1

@interface CMeshLoader ()
@property (readwrite, nonatomic, strong) NSURL *URL;
@property (readwrite, nonatomic, strong) NSDictionary *modelDictioary;
@property (readwrite, nonatomic, strong) CMesh *mesh;
@property (readwrite, nonatomic, strong) NSMutableDictionary *buffers;
@property (readwrite, nonatomic, strong) NSMutableDictionary *materials;

- (CVertexBufferReference *)vertexBufferReferenceWithDictionary:(NSDictionary *)inRepresentation error:(NSError **)outError;
- (CVertexBuffer *)vertexBufferWithPropertyListRepresentation:(id)inRepresentation error:(NSError **)outError;
- (CMutableMaterial *)materialWithPropertyListRepresentation:(id)inRepresentation error:(NSError **)outError;

@end

#pragma mark -

@implementation CMeshLoader

@synthesize URL;
@synthesize modelDictioary;
@synthesize mesh;
@synthesize buffers;
@synthesize materials;

- (BOOL)loadMeshWithURL:(NSURL *)inURL error:(NSError **)outError
	{
    self.URL = inURL;
    
	self.modelDictioary = [NSDictionary dictionaryWithContentsOfURL:inURL];
    if (self.modelDictioary == NULL)
        {
        return(NO);
        }
    
	CMutableMesh *theMesh = [[CMutableMesh alloc] init];

    id theObject = [self.modelDictioary objectForKey:@"center"];
    if (theObject)
        {
        theMesh.center = Vector3FromPropertyListRepresentation(theObject);
        }

    theObject = [self.modelDictioary objectForKey:@"boundingbox"];
    if (theObject)
        {
        theMesh.p1 = Vector3FromPropertyListRepresentation([theObject objectAtIndex:0]);
        theMesh.p2 = Vector3FromPropertyListRepresentation([theObject objectAtIndex:1]);
        }


//  TODO: Reenable model transforms when the model transforms aren't all broken!
//	theObject = [self.modelDictioary objectForKey:@"transform"];
//	if (theObject != NULL)
//		{
//		theMesh.transform = Matrix4FromPropertyListRepresentation(theObject);
//		}

    theMesh.programName = [self.modelDictioary objectForKey:@"programName"];
//    if (theMesh.programName.length == 0)
//        {
//        theMesh.programName = @"Lighting_PerPixel";
//        }

    theMesh.cullBackFaces = [[self.modelDictioary objectForKey:@"cullBackFaces"] boolValue];

    // #### Materials
    self.materials = [NSMutableDictionary dictionary];
	NSDictionary *theMaterialsDictionary = [self.modelDictioary objectForKey:@"materials"];
	for (NSString *theName in theMaterialsDictionary)
		{
		NSDictionary *theMaterialDictionary = [theMaterialsDictionary objectForKey:theName];
		
		CMutableMaterial *theMaterial = [self materialWithPropertyListRepresentation:theMaterialDictionary error:outError];
        if (theMaterial == NULL)
            {
            return(NO);
            }
        theMaterial.name = theName;
		
		[self.materials setObject:theMaterial forKey:theName];
		}

	// #### Buffers
	self.buffers = [NSMutableDictionary dictionary];
	NSDictionary *theBuffersDictionary = [self.modelDictioary objectForKey:@"buffers"];
	for (NSString *theBufferName in theBuffersDictionary)
		{
		NSDictionary *theBufferDictionary = [theBuffersDictionary objectForKey:theBufferName];
		
		CVertexBuffer *theVertexBuffer = [self vertexBufferWithPropertyListRepresentation:theBufferDictionary error:outError];
        if (theVertexBuffer == NULL)
            {
            return(NO);
            }
		
		[self.buffers setObject:theVertexBuffer forKey:theBufferName];
		}

	// #### Geometries...
	NSMutableArray *theGeometries = [NSMutableArray array];
	for (NSDictionary *theGeometryDictionary in [self.modelDictioary objectForKey:@"geometries"])
		{
		CGeometry *theGeometry = [[CGeometry alloc] init];
		
        NSString *theMaterialName = [theGeometryDictionary objectForKey:@"material"];
        CMaterial *theMaterial = [self.materials objectForKey:theMaterialName];
        theGeometry.material = theMaterial;
        
		for (NSString *theKey in [NSArray arrayWithObjects:@"indices", @"positions", @"normals", @"texCoords", NULL])
			{
			NSDictionary *theVerticesDictionary = [theGeometryDictionary objectForKey:theKey];
			if (theVerticesDictionary != NULL)
				{
				CVertexBufferReference *theVertexBufferReference = [self vertexBufferReferenceWithDictionary:theVerticesDictionary error:outError];
				if (theVertexBufferReference == NULL)
					{
					return(NO);
					}
				[theGeometry setValue:theVertexBufferReference forKey:theKey];
				}
			}

		[theGeometries addObject:theGeometry];
		}

	theMesh.geometries = theGeometries;

    self.mesh = theMesh;

	return(YES);
	}

- (CVertexBufferReference *)vertexBufferReferenceWithDictionary:(NSDictionary *)inRepresentation error:(NSError **)outError
	{
    NSNumber *theNumber = [(NSDictionary *)inRepresentation objectForKey:@"size"];
    NSAssert(NO_DEFAULTS && theNumber != NULL, @"No size specified.");
    GLint theSize = [theNumber intValue] ?: 3;

    NSString *theString = [(NSDictionary *)inRepresentation objectForKey:@"type"];
    NSAssert(NO_DEFAULTS && theString.length > 0, @"No type specified.");
    GLenum theType = GLenumFromString(theString) ?: GL_FLOAT;

    theString = [(NSDictionary *)inRepresentation objectForKey:@"normalized"];
    NSAssert(NO_DEFAULTS && theNumber != NULL, @"No normalized specified.");
    GLboolean theNormalized = [theString boolValue] ?: GL_FALSE;

    theString = [(NSDictionary *)inRepresentation objectForKey:@"stride"];
    NSAssert(NO_DEFAULTS && theNumber != NULL, @"No stride specified.");
    GLint theStride = [theString intValue];

    theString = [(NSDictionary *)inRepresentation objectForKey:@"offset"];
    NSAssert(NO_DEFAULTS && theNumber != NULL, @"No offset specified.");
    GLint theOffset = [theString intValue];

    NSString *theBufferName = [(NSDictionary *)inRepresentation objectForKey:@"buffer"];
    CVertexBuffer *theVertexBuffer = [self.buffers objectForKey:theBufferName];

    GLint theRowSize = 0;

    if (theStride != 0)
        {
        theRowSize = theStride;
        }
    else if (theType == GL_FLOAT)
        {
        theRowSize = sizeof(GLfloat) * theSize;
        }
    else if (theType == GL_SHORT)
        {
        theRowSize = sizeof(GLshort) * theSize;
        }
    else
        {
        NSAssert(NO, @"Unknown GLType");
        return(NULL);
        }

    if (theRowSize != 0 && theVertexBuffer.data.length % theRowSize != 0)
        {
        if (outError != NULL)
            {
            *outError = [NSError errorWithDomain:@"TODO_DOMAIN" code:-1 userInfo:NULL];
            }
        return(NULL);
        }

    GLint theRowCount = theRowSize != 0 ? (GLint)(theVertexBuffer.data.length / theRowSize) : 0;

	CVertexBufferReference *theVertexBufferReference = [[CVertexBufferReference alloc] initWithVertexBuffer:theVertexBuffer rowSize:theRowSize rowCount:theRowCount size:theSize type:theType normalized:theNormalized stride:theStride offset:theOffset];
	return(theVertexBufferReference);
	}

- (CVertexBuffer *)vertexBufferWithPropertyListRepresentation:(id)inRepresentation error:(NSError **)outError;
    {
    NSURL *theDirectoryURL = [self.URL URLByDeletingLastPathComponent];
    
    NSString *theString = [(NSDictionary *)inRepresentation objectForKey:@"target"];
    NSAssert(NO_DEFAULTS && theString.length > 0, @"No target specified.");
    GLenum theTarget = GLenumFromString(theString) ?: GL_ARRAY_BUFFER;
    
    theString = [(NSDictionary *)inRepresentation objectForKey:@"usage"];
    NSAssert(NO_DEFAULTS && theString.length > 0, @"No usage specified.");
    GLenum theUsage = GLenumFromString(theString) ?: GL_STATIC_DRAW;
    
    NSData *theData = NULL;

    if ((theString = [(NSDictionary *)inRepresentation objectForKey:@"floats"]) != NULL && theString.length > 0)
        {
        theData = [NSData dataWithNumbersInString:theString type:kCFNumberFloat32Type error:outError];
        if (theData == NULL)
            {
            return(NULL);
            }
        }
    else if ((theString = [(NSDictionary *)inRepresentation objectForKey:@"shorts"]) != NULL && theString.length > 0)
        {
        theData = [NSData dataWithNumbersInString:theString type:kCFNumberShortType error:outError];
        if (theData == NULL)
            {
            return(NULL);
            }
        }
    else
        {
        NSString *theHREF = [(NSDictionary *)inRepresentation objectForKey:@"href"];
        
        NSURL *theURL = [theDirectoryURL URLByAppendingPathComponent:theHREF];
        NSError *theError = NULL;
        theData = [NSData dataWithContentsOfURL:theURL options:0 error:&theError];

        if (theData == NULL)
            {
            NSLog(@"Could not load data for %@ %@", theURL, theError);
            return(NULL);
            }
        }
        

    CVertexBuffer *theVertexBuffer = [[CVertexBuffer alloc] initWithTarget:theTarget usage:theUsage data:theData];
	return(theVertexBuffer);
	}

- (CMutableMaterial *)materialWithPropertyListRepresentation:(id)inRepresentation error:(NSError **)outError
    {
    #pragma unused (outError)
    
    CMutableMaterial *theMaterial = [[CMutableMaterial alloc] init];

//    theMaterial.name = [inRepresentation objectForKey:@"name"];
    id theObject = [(NSDictionary *)inRepresentation objectForKey:@"ambientColor"];
    if (theObject != NULL)
        {
        theMaterial.ambientColor = Color4fFromPropertyListRepresentation(theObject);
        }

    theObject = [(NSDictionary *)inRepresentation objectForKey:@"diffuseColor"];
    if (theObject != NULL)
        {
        theMaterial.diffuseColor = Color4fFromPropertyListRepresentation(theObject);
        }

    theObject = [(NSDictionary *)inRepresentation objectForKey:@"specularColor"];
    if (theObject != NULL)
        {
        theMaterial.specularColor = Color4fFromPropertyListRepresentation(theObject);
        }

    theObject = [(NSDictionary *)inRepresentation objectForKey:@"alpha"];
    if (theObject != NULL)
        {
        theMaterial.alpha = [theObject doubleValue];
        }

    theObject = [(NSDictionary *)inRepresentation objectForKey:@"texture"];
    if (theObject != NULL)
        {
        NSURL *theURL = [[self.URL URLByDeletingLastPathComponent] URLByAppendingPathComponent:theObject];
        
        #if TARGET_OS_IPHONE
        NSData *theData = [NSData dataWithContentsOfURL:theURL options:0 error:outError];
        if (theData == NULL)
            {
            return(NULL);
            }
        UIImage *theImage = [UIImage imageWithData:theData];
        CGImageRef theImageRef = [theImage CGImage];
        #else
        NSImage *theImage = [[NSImage alloc] initWithContentsOfURL:theURL];
        CGImageRef theImageRef = [theImage CGImageForProposedRect:NULL context:NULL hints:NULL];
        #endif

        if (theImageRef)
            {
            CLazyTexture *theTexture = [(CLazyTexture *)[CLazyTexture alloc] initWithImage:theImageRef flip:NO generateMipMap:NO];
            theMaterial.texture = theTexture;
            }
        }


    return(theMaterial);
    }

@end

//
//  COBJParser.m
//  ModelViewer_OSX
//
//  Created by Jonathan Wight on 8/30/11.
//  Copyright (c) 2011 Jonathan Wight. All rights reserved.
//

#import "COBJParser.h"

#import "CMTLParser.h"
#import "CMaterial.h"
#import "CGeometry.h"
#import "CMesh.h"
#import "CVertexBuffer.h"
#import "CVertexBuffer_FactoryExtensions.h"
#import "CVertexBufferReference.h"

@interface COBJParser ()

@property (readwrite, nonatomic, retain) CMesh *mesh;

@end

#pragma mark -

@implementation COBJParser

@synthesize URL;
@synthesize mesh;

- (id)initWithURL:(NSURL *)inURL;
    {
    if ((self = [super init]) != NULL)
        {
        URL = inURL;
        }
    return self;
    }

- (BOOL)parse:(NSError **)outError
    {
    NSError *theError = NULL;
    NSURL *theURL = [self.URL URLByResolvingSymlinksInPath];
    NSString *theString = [NSString stringWithContentsOfURL:theURL encoding:NSUTF8StringEncoding error:&theError];
    NSArray *theLines = [theString componentsSeparatedByString:@"\n"];
    
    NSDictionary *theCurrentMaterials = NULL;
    CMaterial *theCurrentMaterial = NULL;
    NSMutableArray *theInputPositions = [NSMutableArray array];
    NSMutableArray *theInputTexCoords = [NSMutableArray array];
    NSMutableArray *theInputNormals = [NSMutableArray array];

    NSMutableData *theOutputVertices = [NSMutableData data];
    NSMutableArray *theCurrentIndices = NULL;
    NSMutableArray *theGeometries = [NSMutableArray array];

    
    for (NSString *theLine in theLines)
        {
        NSScanner *theScanner = [NSScanner scannerWithString:theLine];
        
        theString = [theString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (theString.length == 0)
            {
            NSLog(@"Empty string. Skipping.");
            }
        else if ([theScanner scanString:@"#" intoString:NULL])
            {
            NSLog(@"Comment. Skipping");
            }
        else if ([theScanner scanString:@"mtllib" intoString:NULL])
            {
            NSString *theName = NULL;
            [theScanner scanCharactersFromSet:[[NSCharacterSet whitespaceAndNewlineCharacterSet] invertedSet] intoString:&theName];
            
            NSURL *theURL = [[self.URL URLByDeletingLastPathComponent] URLByAppendingPathComponent:theName];
            
            CMTLParser *theParser = [[CMTLParser alloc] initWithURL:theURL];
            NSError *theError = NULL;
            [theParser parse:&theError];
            
            theCurrentMaterials = theParser.materials;
            }
        else if ([theScanner scanString:@"usemtl" intoString:NULL])
            {
            if (theCurrentMaterial != NULL)
                {
                CGeometry *theGeometry = [[CGeometry alloc] init];

                NSLog(@"%@ %@", theCurrentMaterial.name, theCurrentIndices);

                CVertexBuffer *theIndicesBuffer = [CVertexBuffer vertexBufferWithIndices:theCurrentIndices];

                theGeometry.material = theCurrentMaterial;
                theGeometry.indices = [[CVertexBufferReference alloc] initWithVertexBuffer:theIndicesBuffer cellEncoding:@encode(GLushort) normalized:YES];
                
                [theGeometries addObject:theGeometry];
                }
            
            theCurrentIndices = [NSMutableArray array];
            
            
            NSString *theName = NULL;
            [theScanner scanCharactersFromSet:[[NSCharacterSet whitespaceAndNewlineCharacterSet] invertedSet] intoString:&theName];

            theCurrentMaterial = [theCurrentMaterials objectForKey:theName];
            }
        else if ([theScanner scanString:@"vt" intoString:NULL])
            {
            Vector2 theVector;
            
            [theScanner scanFloat:&theVector.x];
            [theScanner scanFloat:&theVector.y];

            [theInputTexCoords addObject:[NSValue valueWithBytes:&theVector objCType:@encode(Vector2)]];
            }
        else if ([theScanner scanString:@"vn" intoString:NULL])
            {
            Vector3 theVector;
            
            [theScanner scanFloat:&theVector.x];
            [theScanner scanFloat:&theVector.y];
            [theScanner scanFloat:&theVector.z];

            [theInputNormals addObject:[NSValue valueWithBytes:&theVector objCType:@encode(Vector3)]];
            }
        else if ([theScanner scanString:@"v" intoString:NULL])
            {
            Vector3 theVector;
            
            [theScanner scanFloat:&theVector.x];
            [theScanner scanFloat:&theVector.y];
            [theScanner scanFloat:&theVector.z];

            [theInputPositions addObject:[NSValue valueWithBytes:&theVector objCType:@encode(Vector3)]];
            }
        else if ([theScanner scanString:@"f" intoString:NULL])
            {
            NSString *theString = NULL;
            [theScanner scanCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789/ "] intoString:&theString];
            
            NSArray *theVertexGroups = [theString componentsSeparatedByString:@" "];
            for (NSString *theVertexGroup in theVertexGroups)
                {
                NSArray *theIndices = [theVertexGroup componentsSeparatedByString:@"/"];

                // TODO this assumes that we have indexes for all three vertex types

                Vector3 theVertex3;
                Vector2 theVertex2;

                NSUInteger thePositionIndex = [[theIndices objectAtIndex:0] integerValue] - 1;
                NSValue *theValue = [theInputPositions objectAtIndex:thePositionIndex];
                [theValue getValue:&theVertex3];
                [theOutputVertices appendBytes:&theVertex3 length:sizeof(theVertex3)];
                
                NSUInteger theTexCoordIndex = [[theIndices objectAtIndex:1] integerValue] - 1;
                theValue = [theInputTexCoords objectAtIndex:theTexCoordIndex];
                [theValue getValue:&theVertex2];
                [theOutputVertices appendBytes:&theVertex2 length:sizeof(theVertex2)];
                
                NSUInteger theNormalIndex = [[theIndices objectAtIndex:2] integerValue] - 1;
                theValue = [theInputNormals objectAtIndex:theNormalIndex];
                [theValue getValue:&theVertex3];
                [theOutputVertices appendBytes:&theVertex3 length:sizeof(theVertex3)];

                [theCurrentIndices addObject:[NSNumber numberWithUnsignedLong:theCurrentIndices.count]];
                }
            }

//
//            elif theVerb == 'v':
//                self.positions.append(tuple([float(x) for x in re.split(' +', theParameters)]))
//            elif theVerb == 'vt':
//                self.texCoords.append(tuple([float(x) for x in re.split(' +', theParameters)]))
//            elif theVerb == 'vn':
//                self.normals.append(tuple([float(x) for x in re.split(' +', theParameters)]))
        }


    CVertexBuffer *theVertexBuffer = [[CVertexBuffer alloc] initWithTarget:GL_ARRAY_BUFFER usage:GL_STATIC_DRAW data:theOutputVertices];

    GLint theRowSize = sizeof(Vector3) + sizeof(Vector2) + sizeof(Vector3);
    GLint theSize = (GLint)theOutputVertices.length;
    GLint theRowCount = theSize / theRowSize;

    CVertexBufferReference *thePositionsVertexBufferReference = [[CVertexBufferReference alloc] initWithVertexBuffer:theVertexBuffer rowSize:theRowSize rowCount:theRowCount size:3 type:GL_FLOAT normalized:YES stride:theRowSize offset:0];
    CVertexBufferReference *theTexCoordsVertexBufferReference = [[CVertexBufferReference alloc] initWithVertexBuffer:theVertexBuffer rowSize:theRowSize rowCount:theRowCount size:2 type:GL_FLOAT normalized:YES stride:theRowSize offset:3 * sizeof(GLfloat)];
    CVertexBufferReference *theNormalsVertexBufferReference = [[CVertexBufferReference alloc] initWithVertexBuffer:theVertexBuffer rowSize:theRowSize rowCount:theRowCount size:3 type:GL_FLOAT normalized:NO stride:theRowSize offset:5 * sizeof(GLfloat)];

    for (CGeometry *theGeometry in theGeometries)
        {
        theGeometry.positions = thePositionsVertexBufferReference;
        theGeometry.texCoords = theTexCoordsVertexBufferReference;
        theGeometry.normals = theNormalsVertexBufferReference;
        }

    CMutableMesh *theMesh = [[CMutableMesh alloc] init];
    theMesh.geometries = theGeometries;
    self.mesh = theMesh;


    return(YES);
    }


@end

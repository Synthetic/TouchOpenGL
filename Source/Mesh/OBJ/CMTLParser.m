//
//  CMTLParser.m
//  ModelViewer_OSX
//
//  Created by Jonathan Wight on 8/30/11.
//  Copyright (c) 2011 Jonathan Wight. All rights reserved.
//

#import "CMTLParser.h"

#import "CMaterial.h"
#import "CLazyTexture.h"

@interface CMTLParser ()
@property (readwrite, nonatomic, strong) NSDictionary *materials;
@end

@implementation CMTLParser

@synthesize URL;
@synthesize materials;

- (id)initWithURL:(NSURL *)inURL;
    {
    if ((self = [super init]) != NULL)
        {
        URL = inURL;
        }
    return self;
    }

- (BOOL)parse:(NSError **)outError;
    {
    NSError *theError = NULL;
    NSString *theString = [NSString stringWithContentsOfURL:self.URL encoding:NSUTF8StringEncoding error:&theError];
    NSArray *theLines = [theString componentsSeparatedByString:@"\n"];
    
    NSMutableDictionary *theMaterials = [NSMutableDictionary dictionary];
    CMutableMaterial *theCurrentMaterial = NULL;
    
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
        else if ([theScanner scanString:@"newmtl" intoString:NULL])
            {
            if (theCurrentMaterial)
                {
                [theMaterials setObject:theCurrentMaterial forKey:theCurrentMaterial.name];
                }
            
            NSString *theMaterialName = NULL;
            [theScanner scanCharactersFromSet:[[NSCharacterSet whitespaceAndNewlineCharacterSet] invertedSet] intoString:&theMaterialName];
            
            theCurrentMaterial = [[CMutableMaterial alloc] init];
            theCurrentMaterial.name = theMaterialName;

            NSLog(@"New material: %@", theMaterialName);
            }
        else if ([theScanner scanString:@"Ka" intoString:NULL])
            {
            Color4f theColor = { .a = 1.0f };
            [theScanner scanFloat:&theColor.r];
            [theScanner scanFloat:&theColor.g];
            [theScanner scanFloat:&theColor.b];
            
            theCurrentMaterial.ambientColor = theColor;
            }
        else if ([theScanner scanString:@"Kd" intoString:NULL])
            {
            Color4f theColor = { .a = 1.0f };
            [theScanner scanFloat:&theColor.r];
            [theScanner scanFloat:&theColor.g];
            [theScanner scanFloat:&theColor.b];
            
            theCurrentMaterial.diffuseColor = theColor;
            }
        else if ([theScanner scanString:@"Ks" intoString:NULL])
            {
            Color4f theColor = { .a = 1.0f };
            [theScanner scanFloat:&theColor.r];
            [theScanner scanFloat:&theColor.g];
            [theScanner scanFloat:&theColor.b];
            
            theCurrentMaterial.specularColor = theColor;
            }
        else if ([theScanner scanString:@"map_Kd" intoString:NULL])
            {
            NSString *theName = NULL;
            [theScanner scanCharactersFromSet:[[NSCharacterSet whitespaceAndNewlineCharacterSet] invertedSet] intoString:&theName];
            
            NSURL *theURL = [[self.URL URLByDeletingLastPathComponent] URLByAppendingPathComponent:theName];
            
            CLazyTexture *theTexture = [[CLazyTexture alloc] initWithURL:theURL flip:NO generateMipMap:NO];
            theCurrentMaterial.texture = theTexture;
            }
        
//                theCurrentMaterial.specularColor = [float(x) for x in re.split(' +', theParameters)]
//            elif theVerb == 'd':
//                theCurrentMaterial.d = float(theParameters)
//            elif theVerb == 'Ns':
//                theCurrentMaterial.d = float(theParameters)
//            elif theVerb == 'illum':
//                theCurrentMaterial.d = int(theParameters)
//            elif theVerb == 'map_Ka':
//                theCurrentMaterial.map_Ka = theParameters
//            elif theVerb == 'map_Kd':
//                theCurrentMaterial.texture = theParameters
        
        
        
        }
        
    self.materials = theMaterials;

    return(YES);
    }


@end

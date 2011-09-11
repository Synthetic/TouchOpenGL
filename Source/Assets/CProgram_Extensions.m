//
//  CProgram_Extensions.m
//  OpenGLTest
//
//  Created by Jonathan Wight on 9/11/11.
//  Copyright (c) 2011 toxicsoftware.com. All rights reserved.
//

#import "CProgram_Extensions.h"

#import "CShader.h"

@implementation CProgram (Extensions)

- (id)initWithName:(NSString *)inName attributeNames:(NSArray *)inAttributeNames uniformNames:(NSArray *)inUniformNames
    {
    NSArray *theShaders = [NSArray arrayWithObjects:
        [[CShader alloc] initWithName:[NSString stringWithFormat:@"%@.fsh", inName]],
        [[CShader alloc] initWithName:[NSString stringWithFormat:@"%@.vsh", inName]],
        NULL];
    
    if ((self = [self initWithShaders:theShaders attributeNames:inAttributeNames uniformNames:inUniformNames]) != NULL)
        {
        }
    return(self);
    }

- (id)initWithURL:(NSURL *)inURL
    {
    NSDictionary *theProgramDictionary = [NSDictionary dictionaryWithContentsOfURL:inURL];
    if (theProgramDictionary == NULL)
        {
        self = NULL;
        return(NULL);
        }
    
    NSString *theVertexShaderName = [theProgramDictionary objectForKey:@"vertexShader"];
    NSString *theFragmentShaderName = [theProgramDictionary objectForKey:@"fragmentShader"];
    NSArray *theShaders = [NSArray arrayWithObjects:
        [[CShader alloc] initWithName:theFragmentShaderName],
        [[CShader alloc] initWithName:theVertexShaderName],
        NULL];

    NSArray *theAttributeNames = [[theProgramDictionary objectForKey:@"attributes"] valueForKey:@"name"];
    NSArray *theUniformNames = [[theProgramDictionary objectForKey:@"uniforms"] valueForKey:@"name"];

    if ((self = [self initWithShaders:theShaders attributeNames:theAttributeNames uniformNames:theUniformNames]) != NULL)
        {
        }
    return self;
    }

@end

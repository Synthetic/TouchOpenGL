//
//  CSimplePreprocessor.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 2/22/12.
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

#import "CSimplePreprocessor.h"

typedef enum {
	kTokenType_Unknown,
	kTokenType_Source,
	kTokenType_Include,
	} ETokenType;

@interface CSimplePreprocessorToken : NSObject
@property (readwrite, nonatomic, assign) ETokenType type;
@property (readwrite, nonatomic, strong) NSString *value;
@end

#pragma mark -

@implementation CSimplePreprocessorToken

@synthesize type = _type;
@synthesize value = _value;

- (NSString *)description
    {
    return([NSString stringWithFormat:@"%d: %@", self.type, self.value]);
    }
@end

#pragma mark -

@implementation CSimplePreprocessor

@synthesize loader = _loader;

- (NSString *)preprocess:(NSString *)inSource error:(NSError **)outError;
	{
	NSArray *theTokens = [self tokensForSource:inSource error:outError];
	theTokens = [self processTokens:theTokens error:outError];
	NSString *theString = [self flattenTokens:theTokens error:outError];
	return(theString);
	}
	
- (NSArray *)tokensForSource:(NSString *)inSource error:(NSError **)outError;
	{
	NSMutableArray *theTokens = [NSMutableArray array];

	NSScanner *theScanner = [NSScanner scannerWithString:inSource];
	theScanner.charactersToBeSkipped = [NSCharacterSet whitespaceCharacterSet];
	
	inSource = [inSource stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
	
	while (theScanner.isAtEnd == NO)
		{
		if ([theScanner scanString:@"//" intoString:NULL] == YES)
			{
			[theScanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:NULL];
			[theScanner scanCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:NULL];
			}
		
		if ([theScanner scanString:@"/*" intoString:NULL] == YES)
			{
			[theScanner scanUpToString:@"*/" intoString:NULL];
			[theScanner scanString:@"*/" intoString:NULL];
			}
			
		if ([theScanner scanString:@"#include" intoString:NULL] == YES)
			{
			if ([theScanner scanString:@"<" intoString:NULL] == YES)
				{
				NSString *theFile = NULL;
				if ([theScanner scanUpToString:@">" intoString:&theFile] == YES)
					{
					CSimplePreprocessorToken *theToken = [[CSimplePreprocessorToken alloc] init];
					theToken.type = kTokenType_Include;
					theToken.value = theFile;
					[theTokens addObject:theToken];

					theToken = [[CSimplePreprocessorToken alloc] init];
					theToken.type = kTokenType_Source;
					theToken.value = @"\n";
					[theTokens addObject:theToken];
					}
				[theScanner scanString:@">" intoString:NULL];

				[theScanner scanCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:NULL];
				}
			else if ([theScanner scanString:@"\"" intoString:NULL] == YES)
				{
				NSString *theFile = NULL;
				if ([theScanner scanUpToString:@"\"" intoString:&theFile] == YES)
					{
					CSimplePreprocessorToken *theToken = [[CSimplePreprocessorToken alloc] init];
					theToken.type = kTokenType_Include;
					theToken.value = theFile;
					[theTokens addObject:theToken];

					theToken = [[CSimplePreprocessorToken alloc] init];
					theToken.type = kTokenType_Source;
					theToken.value = @"\n";
					[theTokens addObject:theToken];
					}
				[theScanner scanString:@"\"" intoString:NULL];

				[theScanner scanCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:NULL];
				}
			}
		
		NSString *theString = NULL;
		if ([theScanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&theString] == YES)
			{
			CSimplePreprocessorToken *theToken = [[CSimplePreprocessorToken alloc] init];
			theToken.type = kTokenType_Source;
			theToken.value = theString;
			[theTokens addObject:theToken];
			}
		if ([theScanner scanCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&theString] == YES)
			{
			CSimplePreprocessorToken *theToken = [[CSimplePreprocessorToken alloc] init];
			theToken.type = kTokenType_Source;
			theToken.value = theString;
			[theTokens addObject:theToken];
			}
		
		}
		
	return(theTokens);
	}

- (NSArray *)processTokens:(NSArray *)inTokens error:(NSError **)outError
	{
	NSMutableArray *theInputTokens = [inTokens mutableCopy];
	NSMutableArray *theOutputTokens = [NSMutableArray array];

	for (NSUInteger N = 0; N != theInputTokens.count; ++N)
		{
		CSimplePreprocessorToken *theToken = [theInputTokens objectAtIndex:N];

		if (theToken.type == kTokenType_Include)
			{
			NSString *theIncludedSource = self.loader(theToken.value);
			
			NSArray *theIncludedTokens = [self tokensForSource:theIncludedSource error:NULL];
			
			[theInputTokens replaceObjectsInRange:(NSRange){ N, 1 } withObjectsFromArray:theIncludedTokens];
			N -= 1;
			}
		else
			{
			[theOutputTokens addObject:theToken];
			}
		}

	return(theOutputTokens);
	}
	
- (NSString *)flattenTokens:(NSArray *)inTokens error:(NSError **)outError
	{
	NSMutableString *theString = [NSMutableString string];
	for (CSimplePreprocessorToken *theToken in inTokens)
		{
		if (theToken.type == kTokenType_Source)
			{
			[theString appendString:theToken.value];
			}
		}
	return(theString);
	}

@end

//
//  CSimplePreprocessor.m
//  Preprocessor
//
//  Created by Jonathan Wight on 2/22/12.
//  Copyright (c) 2012 toxicsoftware.com. All rights reserved.
//

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
- (NSString *)description
    {
    return([NSString stringWithFormat:@"%d: %@", self.type, self.value]);
    }
@end

#pragma mark -

@implementation CSimplePreprocessor

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

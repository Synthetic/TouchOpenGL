//
//  NSData_NumberExtensions.m
//  TouchOpenGL
//
//  Created by Jonathan Wight on 03/19/11.
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

#import "NSData_NumberExtensions.h"


@implementation NSData (NSData_NumberExtensions)

+ (NSData *)dataWithNumbersInString:(NSString *)inString type:(CFNumberType)inType error:(NSError **)outError
    {
    #pragma unused (outError)
    
    NSMutableData *theData = [ NSMutableData data];
    
    NSScanner *theScanner = [NSScanner scannerWithString:inString];
    [theScanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@" \t\r\n|;(){}[],"]];
    
    while ([theScanner isAtEnd] == NO)
        {
        switch (inType)
            {
            case kCFNumberFloat32Type:
            case kCFNumberFloatType:
                {
                float theValue;
                if ([theScanner scanFloat:&theValue])
                    {
                    [theData appendBytes:&theValue length:sizeof(theValue)];
                    }
                }
                break;
            case kCFNumberFloat64Type:
            case kCFNumberDoubleType:
                {
                double theValue;
                if ([theScanner scanDouble:&theValue])
                    {
                    [theData appendBytes:&theValue length:sizeof(theValue)];
                    }
                }
                break;
			case kCFNumberSInt8Type:
                {
                NSInteger theInteger;
                if ([theScanner scanInteger:&theInteger])
                    {
					SInt8 theValue = theInteger;
                    [theData appendBytes:&theValue length:sizeof(theValue)];
                    }
                }
                break;
			case kCFNumberSInt16Type:
                {
                NSInteger theInteger;
                if ([theScanner scanInteger:&theInteger])
                    {
					SInt16 theValue = theInteger;
                    [theData appendBytes:&theValue length:sizeof(theValue)];
                    }
                }
                break;
			case kCFNumberSInt32Type:
                {
                NSInteger theInteger;
                if ([theScanner scanInteger:&theInteger])
                    {
					SInt32 theValue = (SInt32)theInteger;
                    [theData appendBytes:&theValue length:sizeof(theValue)];
                    }
                }
                break;
			case kCFNumberSInt64Type:
                {
                NSInteger theInteger;
                if ([theScanner scanInteger:&theInteger])
                    {
					SInt64 theValue = theInteger;
                    [theData appendBytes:&theValue length:sizeof(theValue)];
                    }
                }
                break;
			case kCFNumberCharType:
                {
                NSInteger theInteger;
                if ([theScanner scanInteger:&theInteger])
                    {
					char theValue = theInteger;
                    [theData appendBytes:&theValue length:sizeof(theValue)];
                    }
                }
                break;
			case kCFNumberShortType:
                {
                NSInteger theInteger;
                if ([theScanner scanInteger:&theInteger])
                    {
					short theValue = theInteger;
                    [theData appendBytes:&theValue length:sizeof(theValue)];
                    }
                }
                break;
			case kCFNumberIntType:
                {
                int theValue;
                if ([theScanner scanInt:&theValue])
                    {
                    [theData appendBytes:&theValue length:sizeof(theValue)];
                    }
                }
                break;
			case kCFNumberLongType:
                {
                NSInteger theInteger;
                if ([theScanner scanInteger:&theInteger])
                    {
					long theValue = theInteger;
                    [theData appendBytes:&theValue length:sizeof(theValue)];
                    }
                }
                break;
			case kCFNumberLongLongType:
                {
                long long theValue;
                if ([theScanner scanLongLong:&theValue])
                    {
                    [theData appendBytes:&theValue length:sizeof(theValue)];
                    }
                }
                break;
			case kCFNumberCFIndexType:
                {
                NSInteger theInteger;
                if ([theScanner scanInteger:&theInteger])
                    {
					CFIndex theValue = theInteger;
                    [theData appendBytes:&theValue length:sizeof(theValue)];
                    }
                }
                break;
			case kCFNumberNSIntegerType:
                {
                NSInteger theValue;
                if ([theScanner scanInteger:&theValue])
                    {
                    [theData appendBytes:&theValue length:sizeof(theValue)];
                    }
                }
                break;
			case kCFNumberCGFloatType:
                {
                double theDouble;
                if ([theScanner scanDouble:&theDouble])
                    {
					CGFloat theValue = theDouble;
                    [theData appendBytes:&theValue length:sizeof(theValue)];
                    }
                }
                break;
            default:
				{
				if (outError)
					{
					}
				return(NULL);
				}
                break;
            }

        // TODO support more data types

        }

    return([[theData copy] autorelease]);
    }

@end

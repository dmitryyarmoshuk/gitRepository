//
//  NSData+ZVeqtr.m
//  ZVeqtr
//
//  Created by Leonid Lo on 10/17/12.
//  Copyright (c) 2012 PE-Leonid.Lo. All rights reserved.
//

#import "NSData+ZVeqtr.h"

@implementation NSData (ZVeqtr)


- (NSString *)hexString {
	NSMutableString *str = [NSMutableString stringWithCapacity:[self length]*2+2];
	const char* bytes = (const char*)[self bytes];
	for (int i=0; i < [self length]; ++i) {
		int n = 0xFF & bytes[i];
		[str appendFormat:@"%02X", n];
	}
	return str;
}

@end

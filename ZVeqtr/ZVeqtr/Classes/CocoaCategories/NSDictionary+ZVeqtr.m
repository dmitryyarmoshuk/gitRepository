//
//  NSDictionary+ZVeqtr.m
//  ZVeqtr
//
//  Created by Leonid Lo on 10/15/12.
//  Copyright (c) 2012 PE-Leonid.Lo. All rights reserved.
//

#import "NSDictionary+ZVeqtr.h"

@implementation NSDictionary (ZVeqtr)

+ (NSDictionary *)dictionaryWithResponseString:(NSString *)string {
	NSArray *components = [string componentsSeparatedByString:@"&"];
	NSMutableDictionary *resultDic = [NSMutableDictionary dictionaryWithCapacity:[components count]];
	for (NSString *component in components) {
		NSArray *keyValue = [component componentsSeparatedByString:@"="];
		if (keyValue.count >= 2) {
			NSString *key = [keyValue[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			NSString *val;
			if (keyValue.count > 2) {
				//	a value may contain '=' symbols
				NSArray *arrVal = [keyValue subarrayWithRange:NSMakeRange(1, keyValue.count - 1)];
				val = [arrVal componentsJoinedByString:@"="];
			}
			else {
				val = keyValue[1];
			}
			val = [val stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

			//	val may be an empty string
			if (0 != key.length) {
				resultDic[key] = val;
			}
		}
	}
	return resultDic;
}

@end

//
//  NSString+ZVeqtr.m
//  ZVeqtr
//
//  Created by Leonid Lo on 10/15/12.
//  Copyright (c) 2012 PE-Leonid.Lo. All rights reserved.
//

#import "NSString+ZVeqtr.h"

@implementation NSString (ZVeqtr)

- (NSString *)docPath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *docsDir = paths[0];
	
	return [docsDir stringByAppendingPathComponent:self];
}

- (NSString *)trimWhitespace {
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSArray *)extractHashtags {
	
	NSString *str = self;
	NSArray *tags = [str componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@", "]];
	NSMutableArray *arrTags = [NSMutableArray arrayWithCapacity:8];
	for (NSString *substr in tags) {
		NSString *s = [substr trimWhitespace];
		if ([s hasPrefix:@"#"] && ![arrTags containsObject:s]) {
			[arrTags addObject:s];
		}
	}
	return arrTags;
}

NSString * CHECK_STRING(id object) {
	
	NSString *candidateString = nil;
	if ([object isKindOfClass:[NSString class]]) {
		candidateString = object;
	}
	if (!candidateString && ![object isKindOfClass:[NSNull class]]) {
		candidateString = [object description];
	}
	return candidateString.length ? candidateString : nil;
}

@end

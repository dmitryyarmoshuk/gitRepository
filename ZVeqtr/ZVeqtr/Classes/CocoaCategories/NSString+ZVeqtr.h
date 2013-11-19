//
//  NSString+ZVeqtr.h
//  ZVeqtr
//
//  Created by Leonid Lo on 10/15/12.
//  Copyright (c) 2012 PE-Leonid.Lo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ZVeqtr)

- (NSString *)docPath;
- (NSString *)trimWhitespace;
- (NSArray *)extractHashtags;

NSString * CHECK_STRING(id object);

@end

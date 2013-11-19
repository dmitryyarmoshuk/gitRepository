//
//  ZDateComponents.h
//  ZVeqtr
//
//  Created by Leonid Lo on 12/5/12.
//  Copyright (c) 2012 PE-Leonid.Lo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
	TimeFilterFilter,
	TimeFilterSince,
	TimeFilterRange
} TimeFilter;

@interface ZDateComponents : NSObject
<NSCopying>
@property (nonatomic, assign)	NSUInteger	hours;
@property (nonatomic, assign)	NSUInteger	days;
@property (nonatomic, assign)	NSUInteger	months;
@property (nonatomic, assign)	NSUInteger	years;
//
@property (nonatomic, retain)	NSDate		*dateSince;
@property (nonatomic, retain)	NSDate		*dateRangeFrom;
@property (nonatomic, retain)	NSDate		*dateRangeTo;
//
@property (nonatomic, assign)	TimeFilter	activeTimeFilter;
//

- (NSString*)stringRepresentation;
- (NSDictionary *)dictionaryRepresentation;
+ (ZDateComponents *)dateComponentsWithDictionary:(NSDictionary *)dict;

- (void)reset;

//	@"from_date" / @"to_date" dictionary representation
- (NSDictionary *)dateFilterArguments;

- (BOOL)isEqual:(ZDateComponents *)components2;

@end

//
//  ZDateComponents.m
//  ZVeqtr
//
//  Created by Leonid Lo on 12/5/12.
//  Copyright (c) 2012 PE-Leonid.Lo. All rights reserved.
//

#import "ZDateComponents.h"

@interface ZDateComponents ()
@property (nonatomic, retain) NSDateFormatter *dateFormatter;
@end


@implementation ZDateComponents

- (void)dealloc {
	self.dateRangeFrom = nil;
	self.dateRangeTo = nil;
	self.dateSince = nil;
	self.dateFormatter = nil;
	[super dealloc];
}

- (NSString*)stringRepresentation
{
    NSDateFormatter *df = [[NSDateFormatter new] autorelease];
    //df.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
    //df.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:-7*60*60];
    //[df setDateFormat:@"yyyy-MM-dd"];
    [df setDateStyle:NSDateFormatterMediumStyle];
    
	switch (self.activeTimeFilter) {
			
		case TimeFilterFilter:
        {
            NSString *filterString = @"";
            if(self.years > 0)
            {
                if(self.years == 1)
                    filterString = [filterString stringByAppendingFormat:@"1 year"];
                else
                    filterString = [filterString stringByAppendingFormat:@"%d years", self.years];
            }
            
            if(self.months > 0)
            {
                if(filterString.length > 0)
                    filterString = [filterString stringByAppendingString:@", "];
                
                if(self.months == 1)
                    filterString = [filterString stringByAppendingFormat:@"1 month"];
                else
                    filterString = [filterString stringByAppendingFormat:@"%d months", self.months];
            }
            
            if(self.days > 0)
            {
                if(filterString.length > 0)
                    filterString = [filterString stringByAppendingString:@", "];
                
                if(self.days == 1)
                    filterString = [filterString stringByAppendingFormat:@"1 day"];
                else
                    filterString = [filterString stringByAppendingFormat:@"%d days", self.days];
            }
            
            if(self.hours > 0)
            {
                if(filterString.length > 0)
                    filterString = [filterString stringByAppendingString:@", "];
                
                if(self.hours == 1)
                    filterString = [filterString stringByAppendingFormat:@"1 hour"];
                else
                    filterString = [filterString stringByAppendingFormat:@"%d hours", self.hours];
            }
            
            return filterString;
		}
			
		case TimeFilterSince:
            return [NSString stringWithFormat:@"since %@", [df stringFromDate:self.dateSince]];
		case TimeFilterRange:
			return [NSString stringWithFormat:@"from %@ to %@", [df stringFromDate:self.dateRangeFrom], [df stringFromDate:self.dateRangeTo]];
		default:
			break;
	}//sw
    
    return nil;
}

- (NSDictionary *)dictionaryRepresentation {
	return @{
	@"hours"	: @(self.hours),
	@"days"		: @(self.days),
	@"months"	: @(self.months),
	@"years"	: @(self.years),
	@"activeTimeFilter" : @(self.activeTimeFilter),
	@"dateSince"	 : @([self.dateSince		timeIntervalSinceReferenceDate]),
	@"dateRangeFrom" : @([self.dateRangeFrom	timeIntervalSinceReferenceDate]),
	@"dateRangeTo"	 : @([self.dateRangeTo		timeIntervalSinceReferenceDate]),
	};
}

+ (ZDateComponents *)dateComponentsWithDictionary:(NSDictionary *)dict {
	return [[[self alloc] initWithDictionary:dict] autorelease];
}

- (id)init {
	if ((self = [super init])) {
		self.dateFormatter = [[NSDateFormatter new] autorelease];
		//self.dateFormatter.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
		self.dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
		[self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm':00' '+00:00"];
	}
    
	return self;
}

- (id)initWithDictionary:(NSDictionary *)dict {
	if ((self = [self init])) {
		self.hours	= [dict[@"hours"]	integerValue];
		self.days	= [dict[@"days"]	integerValue];
		self.months = [dict[@"months"]	integerValue];
		self.years	= [dict[@"years"]	integerValue];
		self.activeTimeFilter = [dict[@"activeTimeFilter"]	integerValue];
		
		NSTimeInterval ti;
		ti = [dict[@"dateSince"] doubleValue];
		if (ti > 1) {
			self.dateSince = [NSDate dateWithTimeIntervalSinceReferenceDate:ti];
		}
		ti = [dict[@"dateRangeFrom"] doubleValue];
		if (ti > 1) {
			self.dateRangeFrom = [NSDate dateWithTimeIntervalSinceReferenceDate:ti];
		}
		ti = [dict[@"dateRangeTo"] doubleValue];
		if (ti > 1) {
			self.dateRangeTo = [NSDate dateWithTimeIntervalSinceReferenceDate:ti];
		}
	}
	return self;
}

- (void)reset {
	self.hours	= 0;
	self.days	= 1;
	self.months = 0;
	self.years	= 0;
	self.activeTimeFilter = TimeFilterFilter;
	self.dateSince = [[NSDate date] dateByAddingTimeInterval:-24*60*60];
	self.dateRangeFrom = self.dateSince;
	self.dateRangeTo = nil;
}


#pragma mark -

- (NSDictionary *)dateFilterArguments {
	NSDate *fromDate = nil;
	NSDate *toDate = nil;
	NSDate *now = [NSDate date];
    
	switch (self.activeTimeFilter) {
			
		case TimeFilterFilter: {
			toDate = now;

			NSCalendar *calendar = [NSCalendar currentCalendar];
			NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit;
			NSDateComponents *components = [calendar components:unitFlags fromDate:now];
			components.hour		-= self.hours;
			components.day		-= self.days;
			components.month	-= self.months;
			components.year		-= self.years;
			fromDate = [calendar dateFromComponents:components];

			break;
		}
			
		case TimeFilterSince:
			toDate = now;
			fromDate = self.dateSince ? self.dateSince : [now dateByAddingTimeInterval:-24*60*60];
			
			break;
			
		case TimeFilterRange:
			toDate =  self.dateRangeTo ? self.dateRangeTo : now;
			fromDate = self.dateRangeFrom ? self.dateRangeFrom : [now dateByAddingTimeInterval:-24*60*60];
			
			break;
			
		default:
			break;
	}//sw
	
	return (fromDate == nil || toDate == nil) ? nil :
	@{
			@"from_date"	: [self.dateFormatter stringFromDate:fromDate],
			@"to_date"		: [self.dateFormatter stringFromDate:toDate]
	};
}


- (BOOL)isEqual:(ZDateComponents *)components2 {
	if (self == components2) {
		return YES;
	}
	
	BOOL eq =
	(components2.hours == self.hours) &&
	(components2.days == self.days) &&
	(components2.months == self.months) &&
	(components2.years == self.years) &&
	(components2.activeTimeFilter == self.activeTimeFilter);

	if (eq) {
		eq =
		(components2.dateSince     ==  self.dateSince    || [components2.dateSince		isEqualToDate:self.dateSince]) &&
		(components2.dateRangeFrom == self.dateRangeFrom || [components2.dateRangeFrom	isEqualToDate:self.dateRangeFrom]) &&
		(components2.dateRangeTo   == self.dateRangeTo   || [components2.dateRangeTo	isEqualToDate:self.dateRangeTo]);
	}
	
	return eq;
}


- (id)copyWithZone:(NSZone *)zone {
	
	ZDateComponents *components2 = [[self class] new];

	components2.hours = self.hours;
	components2.days = self.days;
	components2.months = self.months;
	components2.years = self.years;
	components2.dateSince = self.dateSince;
	components2.dateRangeFrom = self.dateRangeFrom;
	components2.dateRangeTo = self.dateRangeTo;
	components2.activeTimeFilter = self.activeTimeFilter;

	return components2;
}

#pragma mark -

- (NSString *)description {
	NSString *state = @"???";
	switch (self.activeTimeFilter) {
		case TimeFilterFilter:			state = @"TimeFilterFilter";		break;
		case TimeFilterSince:			state = @"TimeFilterSince";			break;
		case TimeFilterRange:			state = @"TimeFilterRange";			break;
			
		default:	break;
	}
	return [NSString stringWithFormat:@"<%@:%p> active:'%@'; args:'%@';",
			[self class], self, state, [self dateFilterArguments]];
}

@end

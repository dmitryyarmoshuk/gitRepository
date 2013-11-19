//
//  ZLocationModel.m
//  ZVeqtr
//
//  Created by Lee Loo on 10/17/12.
//  Copyright (c) 2012 PE-Leonid.Lo. All rights reserved.
//

#import "ZLocationModel.h"

@interface ZLocationModel ()
@property (nonatomic, retain) NSNumber *numLat, *numLon;
@end

@implementation ZLocationModel

- (void)dealloc {
	self.numLat = nil;
	self.numLon = nil;
	[super dealloc];
}

- (CLLocationCoordinate2D)coordinate {
    CLLocationCoordinate2D theCoordinate;
    theCoordinate.latitude  = self.numLat ? [self.numLat doubleValue] : 360;
    theCoordinate.longitude = self.numLon ? [self.numLon doubleValue] : 360;
    return theCoordinate;
}

- (void)setCoordinate:(CLLocationCoordinate2D)coordinate {
	self.numLat = @(coordinate.latitude);
	self.numLon = @(coordinate.longitude);
}

- (NSDictionary *)dictionaryRepresentation {
	NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:8];
	if (self.title) {
		dic[@"title"] = self.title;
	}
	if (self.numLat) {
		dic[@"lat"] = self.numLat;
	}
	if (self.numLon) {
		dic[@"lon"] = self.numLon;
	}
	return dic;
}

+ (ZLocationModel *)locationModelWithDictionary:(NSDictionary *)dict {
	if (!dict) {
		return nil;
	}
	ZLocationModel *model = [[self new] autorelease];
	model.title = dict[@"title"];
	model.numLat = dict[@"lat"];
	model.numLon = dict[@"lon"];
	return model;
}

- (NSString *)stringRepresentation {
	return	self.title.length ? self.title :
	[NSString stringWithFormat:@"noname location: %2.2f:%2.2f", [self.numLat floatValue], [self.numLon floatValue]];
}

@end

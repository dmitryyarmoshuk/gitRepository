//
//  ZVenueModel.h
//  ZVeqtr
//
//  Created by Maxim on 6/10/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZVeqtrAnnotation.h"


@interface ZVenueModel : NSObject<ZVeqtrAnnotation>

@property (nonatomic, retain) NSString		*name;
@property (nonatomic, retain) NSString		*ID;
@property (nonatomic, retain) NSString		*address;
@property (nonatomic, retain) NSString		*lat;
@property (nonatomic, retain) NSString		*lon;
@property (nonatomic, retain) NSNumber		*distance;

//
@property (nonatomic, readonly) NSString	*subtitle;
@property (nonatomic, readonly) CLLocationCoordinate2D	coordinate;

+ (ZVenueModel *)modelWithDictionary:(NSDictionary *)dataDict;
+ (ZVenueModel *)modelWithID:(NSString *)ID;

- (BOOL)applyDictionary:(NSDictionary *)dataDict;

- (MKAnnotationView *)annotationViewForMap:(MKMapView *)mapView target:(id)targer action:(SEL)action;
- (MKAnnotationView *)annotationViewForMap:(MKMapView *)mapView target:(id)targer action:(SEL)action showOnMapAction:(SEL)showOnMapAction;

- (BOOL)isEqual:(id)object;

@end

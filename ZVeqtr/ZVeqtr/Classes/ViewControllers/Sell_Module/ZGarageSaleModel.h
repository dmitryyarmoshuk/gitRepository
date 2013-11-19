//
//  ZGarageSaleModel.h
//  ZVeqtr
//
//  Created by Maxim on 4/4/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZVeqtrAnnotation.h"

#define SALE_TYPE_GARAGE_SALE       @"sale"
#define SALE_TYPE_PRODUCT           @"product"
#define SALE_TYPE_SERVICE           @"service"

@interface ZGarageSaleModel : NSObject<ZVeqtrAnnotation>
{}

@property (nonatomic, retain) NSString		*ID;
@property (nonatomic, retain) NSString		*type;
@property (nonatomic, retain) NSString		*name;
@property (nonatomic, retain) NSDate		*startTime;
@property (nonatomic, retain) NSDate		*endTime;

@property (nonatomic, retain) NSString	*publish;

@property (nonatomic, retain) NSString	*company;
@property (nonatomic, retain) NSString	*thumbnail;
@property (nonatomic, retain) NSString	*website;
@property (nonatomic, retain) NSString	*phone;
@property (nonatomic, retain) NSString	*tag1;
@property (nonatomic, retain) NSString	*tag2;
@property (nonatomic, retain) NSString	*tag3;
@property (nonatomic, retain) NSString	*tag4;
@property (nonatomic, retain) NSString	*tag5;

@property (nonatomic, retain) UIImage		*thumbnailImage;

@property (nonatomic, retain) NSString		*location;
@property (nonatomic, retain) NSString		*lat;
@property (nonatomic, retain) NSString		*lon;

@property (nonatomic, retain) NSString		*description;

@property (nonatomic, assign) BOOL			wasUpdated;
@property (nonatomic, readonly) CLLocationCoordinate2D	coordinate;
@property (nonatomic, readonly) CLLocation	*locationCoordinate;

+ (ZGarageSaleModel *)modelWithDictionary:(NSDictionary *)dataDict;
+ (ZGarageSaleModel *)modelWithID:(NSString *)ID;

- (NSString *)pathPicture;

- (BOOL)applyDictionary:(NSDictionary *)dataDict updateId:(BOOL)updateId;

- (MKAnnotationView *)annotationViewForMap:(MKMapView *)mapView target:(id)targer action:(SEL)action;
- (MKAnnotationView *)annotationViewForMap:(MKMapView *)mapView target:(id)targer action:(SEL)action showOnMapAction:(SEL)showOnMapAction;

+(NSString*)inAppPurchaseIdForSaleType:(NSString*)saleType;

@property (nonatomic, readonly) NSString		*title;
@property (nonatomic, readonly) NSString		*typeName;
@property (nonatomic, readonly) NSString		*timePeriod;

- (BOOL)isEqual:(id)object;

@end

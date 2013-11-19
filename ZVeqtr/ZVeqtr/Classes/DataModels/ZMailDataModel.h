//
//  ZMailDataModel.h
//  ZVeqtr
//
//  Created by Leonid Lo on 10/15/12.
//  Copyright (c) 2012 PE-Leonid.Lo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZVeqtrAnnotation.h"


@interface ZMailDataModel : NSObject
<ZVeqtrAnnotation>
{}

@property (nonatomic, retain) NSString		*countComments;
@property (nonatomic, retain) NSString		*descript;
@property (nonatomic, retain) NSString		*ID;
@property (nonatomic, retain) NSString		*userID;
@property (nonatomic, retain) NSString		*lat;
@property (nonatomic, retain) NSString		*lon;
@property (nonatomic, retain) NSString		*privacy;
@property (nonatomic, retain) NSString		*title;
@property (nonatomic, retain) NSString		*rating;
@property (nonatomic, retain) NSString		*toUserId;

//
@property (nonatomic, retain) NSString		*dateString;
@property (nonatomic, retain) NSString		*imageString;
@property (nonatomic, retain) NSString		*statusString;

//
@property (nonatomic, assign) BOOL			wasUpdated;
@property (nonatomic, assign) BOOL			hasImage;
@property (nonatomic, readonly) NSString	*subtitle;
@property (nonatomic, readonly) CLLocationCoordinate2D	coordinate;

+ (ZMailDataModel *)mailDataModelWithDictionary:(NSDictionary *)dataDict;
+ (ZMailDataModel *)modelWithID:(NSString *)ID;

- (BOOL)applyDictionary:(NSDictionary *)dataDict;

- (MKAnnotationView *)annotationViewForMap:(MKMapView *)mapView target:(id)targer action:(SEL)action;
- (MKAnnotationView *)annotationViewForMap:(MKMapView *)mapView target:(id)targer action:(SEL)action showOnMapAction:(SEL)showOnMapAction;

- (BOOL)isEqual:(id)object;
- (void)updateWithMailDataModel:(ZMailDataModel *)newModel;

@end
/*
 User by id response:
 
 date = "2012-11-09 11:32:01";
 description = "Hello my friends";
 id = 100;
 image = 1;
 lat = "33.895782";
 location = "";
 lon = "-118.220100";
 privacy = 0;
 status = 0;
 title = "#compton";
 "user_id" = 47;
*/

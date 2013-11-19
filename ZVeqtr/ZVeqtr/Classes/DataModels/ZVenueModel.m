//
//  ZVenueModel.m
//  ZVeqtr
//
//  Created by Maxim on 6/10/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZVenueModel.h"
#import "ZTaggedButton.h"
#import "ZUserInfoButton.h"


@implementation ZVenueModel

- (void)dealloc {
	[super dealloc];
}

+ (ZVenueModel *)modelWithDictionary:(NSDictionary *)dataDict {
	ZVenueModel *model = [[self new] autorelease];
	if ([model applyDictionary:dataDict]) {
		return model;
	}
	return nil;
}

+ (ZVenueModel *)modelWithID:(NSString *)ID {
	ZVenueModel *model = [[self new] autorelease];
	model.ID = ID;
	return model;
}

- (BOOL)applyDictionary:(NSDictionary *)dataDict {
	if (![dataDict isKindOfClass:[NSDictionary class]]) {
		LLog(@"Wrong argument (%@)", dataDict);
		return NO;
	}
	
	BOOL isOK = NO;
	if (dataDict.count > 5)
    {
        self.name = dataDict[@"name"];
        self.ID = dataDict[@"id"];
        
        self.address = dataDict[@"location"][@"address"];
        self.distance = dataDict[@"location"][@"distance"];
        
        self.lat = dataDict[@"location"][@"lat"];
        self.lon = dataDict[@"location"][@"lng"];
        
		isOK = YES;
	}
	if ([self.ID integerValue]==0) {
		LLog(@"Wrong ID, //dataDict:'%@'", dataDict);
		isOK = NO;
	}
	return isOK;
}

- (CLLocationCoordinate2D)coordinate {
    CLLocationCoordinate2D theCoordinate;
    theCoordinate.latitude	= self.lat ? [self.lat doubleValue] : 360;
    theCoordinate.longitude = self.lon ? [self.lon doubleValue] : 360;
    return theCoordinate;
}

- (NSString *)subtitle {
	return nil;
}

#pragma mark -

- (MKAnnotationView *)annotationViewForMap:(MKMapView *)mapView target:(id)targer action:(SEL)action
{
	return [self annotationViewForMap:mapView target:targer action:action showOnMapAction:nil];
}

- (MKAnnotationView *)annotationViewForMap:(MKMapView *)mapView target:(id)targer action:(SEL)action showOnMapAction:(SEL)showOnMapAction
{
	NSString *annotID = [NSString stringWithFormat:@"ZVenueModel"];
	MKAnnotationView* pinView = [mapView dequeueReusableAnnotationViewWithIdentifier:annotID];
	if(!pinView)
    {
		pinView = [[[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:annotID] autorelease];
        pinView.image = [UIImage imageNamed:@"pin.png"];
        pinView.calloutOffset = CGPointMake(0, 0);
		pinView.canShowCallout = YES;
		pinView.draggable = NO;
		pinView.rightCalloutAccessoryView = [ZTaggedButton buttonWithTarget:targer action:action];
        
//        ZUserInfoButton *taggedButton = [ZUserInfoButton buttonWithType:UIButtonTypeCustom];
//        [taggedButton addTarget:targer action:showOnMapAction forControlEvents:UIControlEventTouchUpInside];
//        taggedButton.frame = CGRectMake(0, 0, 30, 30);
//        UIImage *im = [UIImage imageNamed:@"icon_compass"];
//        [taggedButton setImage:im forState:UIControlStateNormal];
//        pinView.leftCalloutAccessoryView =taggedButton;
	}
	else
	{
		pinView.annotation = self;
	}

	ZTaggedButton *rightButton = (ZTaggedButton *)pinView.rightCalloutAccessoryView;
	rightButton.userInfo = self;
    
//    ZUserInfoButton *leftButton = (ZUserInfoButton *)pinView.leftCalloutAccessoryView;
//    leftButton.userInfo = self;
    
    if (!APP_DLG.currentUser.googleMapVisible) {
        pinView.leftCalloutAccessoryView = nil;
    } else {
        if (pinView.leftCalloutAccessoryView == nil) {
            ZUserInfoButton *taggedButton = [ZUserInfoButton buttonWithType:UIButtonTypeCustom];
            [taggedButton addTarget:targer action:showOnMapAction forControlEvents:UIControlEventTouchUpInside];
            taggedButton.frame = CGRectMake(0, 0, 30, 30);
            UIImage *im = [UIImage imageNamed:@"icon_compass"];
            [taggedButton setImage:im forState:UIControlStateNormal];
            pinView.leftCalloutAccessoryView = taggedButton;
            ZUserInfoButton *leftButton = (ZUserInfoButton *)pinView.leftCalloutAccessoryView;
            leftButton.userInfo = self;
        }
    }
	
	return pinView;
}


- (BOOL)isEqual:(id)object {
	if ([object isKindOfClass:[self class]]) {
		ZVenueModel *model2 = (ZVenueModel *)object;
		return [self.ID isEqual:model2.ID];
	}
	return NO;
}


#pragma mark -

-(NSString*)title
{
    return self.name;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"description"];
}

@end

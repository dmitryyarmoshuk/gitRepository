//
//  ZMailDataModel.m
//  ZVeqtr
//
//  Created by Leonid Lo on 10/15/12.
//  Copyright (c) 2012 PE-Leonid.Lo. All rights reserved.
//

#import "ZMailDataModel.h"
#import "ZTaggedButton.h"
#import "ZUserInfoButton.h"


typedef enum {
	kMailUndef = 0,
	kMailAnnotation = 100,
	kMailOpenAnnotation,
	kMailOnFireAnnotation,
	kMailGreenAnnotation,
	kMailGreenOpenAnnotation,
	kMailGreenOnFireAnnotation,
    kMailRedAnnotation,
    kMailRedOpenAnnotation,
    kMailRedOnFireAnnotation
} MailAnnotationClass;


@implementation ZMailDataModel

- (void)dealloc {
	[super dealloc];
}

+ (ZMailDataModel *)mailDataModelWithDictionary:(NSDictionary *)dataDict {
	ZMailDataModel *model = [[self new] autorelease];
	if ([model applyDictionary:dataDict]) {
		return model;
	}
	return nil;
}

+ (ZMailDataModel *)modelWithID:(NSString *)ID {
	ZMailDataModel *model = [[self new] autorelease];
	model.ID = ID;
	return model;
}

- (BOOL)applyDictionary:(NSDictionary *)dataDict {
	if (![dataDict isKindOfClass:[NSDictionary class]]) {
		LLog(@"Wrong argument (%@)", dataDict);
		return NO;
	}
	
	BOOL isOK = NO;
	if (dataDict.count > 5) {
		self.ID = CHECK_STRING(dataDict[@"id"]);
		self.descript = CHECK_STRING(dataDict[@"description"]);
		self.privacy = CHECK_STRING(dataDict[@"privacy"]);
		self.userID = CHECK_STRING(dataDict[@"user_id"]);
        self.toUserId = CHECK_STRING(dataDict[@"to_user"]);
		self.title = CHECK_STRING(dataDict[@"title"]);
		self.countComments = CHECK_STRING(dataDict[@"comments"]);
		self.rating = CHECK_STRING(dataDict[@"rating"]);
		
		self.dateString = CHECK_STRING(dataDict[@"date"]);
		self.imageString  = CHECK_STRING(dataDict[@"image"]);
		self.statusString = CHECK_STRING(dataDict[@"status"]);

		NSString *coord = CHECK_STRING(dataDict[@"coord"]);
		const NSUInteger n = [coord rangeOfString:@" "].location;
		if (n != NSNotFound) {
			self.lat = [coord substringToIndex:n];
			self.lon = [coord substringFromIndex:n + 1];
		}
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

- (UIImage *)imageByKind {

	static NSDictionary *imgMatrix = nil;
	if (!imgMatrix) {
		imgMatrix = [@{
		@(kMailAnnotation) : @"blue_mail.png",
		@(kMailOpenAnnotation) : @"blue_mail_open.png",
		@(kMailOnFireAnnotation) : @"blue_mail_on_fire.png",
		@(kMailGreenAnnotation) : @"green_mail.png",
		@(kMailGreenOpenAnnotation) : @"green_mail_open.png",
		@(kMailGreenOnFireAnnotation) : @"green_mail_on_fire.png",
        @(kMailRedAnnotation) : @"red_mail",
        @(kMailRedOpenAnnotation) : @"red_mail_open",
        @(kMailRedOnFireAnnotation) : @"red_mail_on_fire"
					 } retain];
	}
	NSString *imgName = imgMatrix[@([self mailKind])];
	return imgName ? [UIImage imageNamed:imgName] : nil;
}

- (MailAnnotationClass)mailKind {
	int privacy = [self.privacy integerValue];
	int countComments = [self.countComments integerValue];
	MailAnnotationClass kind = kMailUndef;
    
	if (privacy == 0) {
		
		if (countComments == 0) {
			kind = kMailAnnotation;
		} else if (countComments < 10) {
			kind = kMailOpenAnnotation;
		} else {
			kind = kMailOnFireAnnotation;
		}
	}
	else if (privacy == 1) {
		
		if (countComments == 0) {
			kind = kMailGreenAnnotation;
		} else if (countComments < 10) {
			kind = kMailGreenOpenAnnotation;
		} else {
			kind = kMailGreenOnFireAnnotation;
		}
	}
    else if(privacy == 5)
    {
        if (countComments == 0) {
			kind = kMailRedAnnotation;
		} else if (countComments < 10) {
          kind = kMailRedOpenAnnotation;
          } else {
              kind = kMailRedOnFireAnnotation;
          }
    }
	
	return kind;
}

- (MKAnnotationView *)annotationViewForMap:(MKMapView *)mapView target:(id)targer action:(SEL)action
{
	return [self annotationViewForMap:mapView target:targer action:action showOnMapAction:nil];
}

- (MKAnnotationView *)annotationViewForMap:(MKMapView *)mapView target:(id)targer action:(SEL)action showOnMapAction:(SEL)showOnMapAction
{
	MailAnnotationClass kind = [self mailKind];
	NSString *annotID = [NSString stringWithFormat:@"mailAnnotationKind_%d", kind];
	MKAnnotationView* pinView = [mapView dequeueReusableAnnotationViewWithIdentifier:annotID];
	if(!pinView)
    {
		pinView = [[[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:annotID] autorelease];
		pinView.canShowCallout = YES;
		pinView.draggable = NO;
		pinView.rightCalloutAccessoryView = [ZTaggedButton buttonWithTarget:targer action:action];
        
//      ZUserInfoButton *taggedButton = [ZUserInfoButton buttonWithType:UIButtonTypeCustom];
//      [taggedButton addTarget:targer action:showOnMapAction forControlEvents:UIControlEventTouchUpInside];
//      taggedButton.frame = CGRectMake(0, 0, 30, 30);
//      UIImage *im = [UIImage imageNamed:@"icon_compass"];
//      [taggedButton setImage:im forState:UIControlStateNormal];
//      pinView.leftCalloutAccessoryView = taggedButton;
	}
	else
	{
		pinView.annotation = self;
	}
	pinView.image = [self imageByKind];
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

- (void)updateWithMailDataModel:(ZMailDataModel *)newModel {
	if (!newModel) {
		LLog(@"NO model, nothing to apply");
		return;
	}
	NSArray *propsToUpdate = @[@"countComments", @"descript", @"userID", @"lat", @"lon", @"privacy", @"title", @"rating"];
	NSDictionary *keyVals = [newModel dictionaryWithValuesForKeys:propsToUpdate];
	[self setValuesForKeysWithDictionary:keyVals];
	self.wasUpdated = YES;
}

- (BOOL)isEqual:(id)object {
	if ([object isKindOfClass:[self class]]) {
		ZMailDataModel *model2 = (ZMailDataModel *)object;
		return [self.ID isEqual:model2.ID];
	}
	return NO;
}

- (BOOL)hasImage {
	return [self.imageString boolValue];
}

#pragma mark -

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@:%p>id:'%@'; descr:'%@'; usrID:'%@'; ttl:'%@'; lat/lon:'%@/%@'; rate:'%@';",
			[self class], self, self.ID, self.descript, self.userID, self.title, self.lat, self.lon, self.rating];
}

@end

//
//  ZGarageSaleModel.m
//  ZVeqtr
//
//  Created by Maxim on 4/4/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZGarageSaleModel.h"
#import "ZTaggedButton.h"
#import "ZUserInfoButton.h"


@interface ZGarageSaleModel()

@property (nonatomic, retain) NSDateFormatter *dateFormatter;

@end


@implementation ZGarageSaleModel

- (void)dealloc {
    self.dateFormatter = nil;
	[super dealloc];
}

- (id)init {
	if ((self = [super init])) {
		self.dateFormatter = [[NSDateFormatter new] autorelease];
		//self.dateFormatter.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
		self.dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
		[self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	}
	return self;
}


+ (ZGarageSaleModel *)modelWithDictionary:(NSDictionary *)dataDict {
	ZGarageSaleModel *model = [[self new] autorelease];
	if ([model applyDictionary:dataDict updateId:YES]) {
		return model;
	}
	return nil;
}

+ (ZGarageSaleModel *)modelWithID:(NSString *)ID {
	ZGarageSaleModel *model = [[self new] autorelease];
	model.ID = ID;
	return model;
}

- (BOOL)applyDictionary:(NSDictionary *)dataDict updateId:(BOOL)updateId
{
	if (![dataDict isKindOfClass:[NSDictionary class]]) {
		LLog(@"Wrong argument (%@)", dataDict);
		return NO;
	}
	
	BOOL isOK = NO;
	if (dataDict.count > 0) {
        if(updateId)
            self.ID = CHECK_STRING(dataDict[@"id"]);
        
        self.type = CHECK_STRING(dataDict[@"type"]);
		self.name = CHECK_STRING(dataDict[@"title"]);
        
        NSString *start = CHECK_STRING(dataDict[@"date_start"]);
		self.startTime = [self.dateFormatter dateFromString:start];
        NSString *end = CHECK_STRING(dataDict[@"date_end"]);
        self.endTime = [self.dateFormatter dateFromString:end];
        self.publish = CHECK_STRING(dataDict[@"publish"]);
        self.company = CHECK_STRING(dataDict[@"company"]);
        
        self.thumbnail = CHECK_STRING(dataDict[@"thumbnail"]);
        self.website = CHECK_STRING(dataDict[@"website"]);
        self.phone = CHECK_STRING(dataDict[@"phone"]);
        
        self.tag1 = CHECK_STRING(dataDict[@"tag1"]);
        self.tag2 = CHECK_STRING(dataDict[@"tag2"]);
        self.tag3 = CHECK_STRING(dataDict[@"tag3"]);
        self.tag4 = CHECK_STRING(dataDict[@"tag4"]);
        self.tag5 = CHECK_STRING(dataDict[@"tag5"]);
		self.location = CHECK_STRING(dataDict[@"location"]);
        self.lat = [NSString stringWithFormat:@"%f", [dataDict[@"lat"] floatValue]];
        self.lon = [NSString stringWithFormat:@"%f", [dataDict[@"lon"] floatValue]];
		self.description = CHECK_STRING(dataDict[@"description"]);

		isOK = YES;
	}
    
	if ([self.ID integerValue]==0)
    {
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

- (CLLocation*)locationCoordinate {
    if(self.lat && self.lon)
    {
        CLLocationCoordinate2D coordinate = self.coordinate;
        
        return [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    }
    
    return nil;
}

- (NSString *)subtitle {
	return nil;
}

- (NSString *)timePeriod
{
    NSString *dateString = @"";
    if(self.startTime)
        dateString = [NSString stringWithFormat:@"from %@ ", [self.dateFormatter stringFromDate:self.startTime]];
    if(self.endTime)
    {
        dateString = [dateString stringByAppendingFormat:@"to %@", [self.dateFormatter stringFromDate:self.endTime]];
    }
    
	return dateString;
}

- (NSString *)pathPicture {
	return [@"sale_thumbnail_image" docPath];
}

- (void)setThumbnailImage:(UIImage *)thumbnail {
	NSString *path = [self pathPicture];
    NSLog(@"%@", path);
    NSError *error = nil;
	[[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    if(error == nil)
    {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    if(thumbnail)
    {
        NSData *imgData = UIImageJPEGRepresentation(thumbnail, 0.8);
        
        BOOL isOK = [imgData writeToFile:path atomically:YES];
        if (!isOK) {
            LLog(@"Cannot save image at path '%@'", path);
        }
    }
}

- (UIImage *)thumbnailImage
{
	NSString *picFile = [self pathPicture];
	LLog(@"%@", picFile);
	NSData *imgData = [NSData dataWithContentsOfFile:picFile];
	return imgData ? [UIImage imageWithData:imgData] : nil;
}

#pragma mark -

- (MKAnnotationView *)annotationViewForMap:(MKMapView *)mapView target:(id)targer action:(SEL)action {
	
	return [self annotationViewForMap:mapView target:targer action:action showOnMapAction:nil];
}

- (MKAnnotationView *)annotationViewForMap:(MKMapView *)mapView target:(id)targer action:(SEL)action showOnMapAction:(SEL)showOnMapAction
{
    NSString *annotID = @"garageSaleAnnotation";
	MKAnnotationView* pinView = [mapView dequeueReusableAnnotationViewWithIdentifier:annotID];
	if(!pinView) {
		pinView = [[[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:annotID] autorelease];
		pinView.canShowCallout = YES;
		pinView.draggable = NO;
		pinView.rightCalloutAccessoryView = [ZTaggedButton buttonWithTarget:targer action:action];
        
//        ZUserInfoButton *taggedButton = [ZUserInfoButton buttonWithType:UIButtonTypeCustom];
//        [taggedButton addTarget:targer action:showOnMapAction forControlEvents:UIControlEventTouchUpInside];
//        taggedButton.frame = CGRectMake(0, 0, 30, 30);
//        UIImage *im = [UIImage imageNamed:@"icon_compass"];
//        [taggedButton setImage:im forState:UIControlStateNormal];
//        pinView.leftCalloutAccessoryView = taggedButton;
	}
	else
	{
		pinView.annotation = self;
	}
    
    if([self.type isEqualToString:SALE_TYPE_GARAGE_SALE])
        pinView.image = [UIImage imageNamed:@"garage_sale_icon_32x32"];
    else if([self.type isEqualToString:SALE_TYPE_PRODUCT])
    {
        if([self.startTime timeIntervalSinceNow] <= 0)
            pinView.image = [UIImage imageNamed:@"product_blue"];
        else
            pinView.image = [UIImage imageNamed:@"product_green"];
    }
    else if([self.type isEqualToString:SALE_TYPE_SERVICE])
    {
        if([self.startTime timeIntervalSinceNow] <= 0)
            pinView.image = [UIImage imageNamed:@"service_blue"];
        else
            pinView.image = [UIImage imageNamed:@"service_green"];
    }
    
	//pinView.image = [UIImage imageNamed:@""];
	ZTaggedButton *rightButton = (ZTaggedButton *)pinView.rightCalloutAccessoryView;
	rightButton.userInfo = self;
    
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

-(NSString*)title
{
    if(self.name)
        return self.name;
    
    return @"";
}

-(NSString*)typeName
{
    if([self.type isEqualToString:SALE_TYPE_GARAGE_SALE])
        return @"Garage Sale";
    if([self.type isEqualToString:SALE_TYPE_PRODUCT])
        return @"Product";
    if([self.type isEqualToString:SALE_TYPE_SERVICE])
        return @"Service";
        
    return @"";
}

+(NSString*)inAppPurchaseIdForSaleType:(NSString*)saleType
{
    if([saleType isEqualToString:SALE_TYPE_GARAGE_SALE])
        return @"com.michaelthemaven.veqtr.garagesal";
    if([saleType isEqualToString:SALE_TYPE_PRODUCT])
        return @"com.michaelthemaven.veqtr.product";
    if([saleType isEqualToString:SALE_TYPE_SERVICE])
        return @"com.michaelthemaven.veqtr.service";
    
    return @"";
}

- (NSDictionary *)dateFilterArguments {
	return (self.startTime == nil || self.endTime == nil) ? nil :
	@{
   @"date_start"	: [self.dateFormatter stringFromDate:self.startTime],
   @"date_end"		: [self.dateFormatter stringFromDate:self.endTime]
   };
}


- (BOOL)isEqual:(id)object {
	if ([object isKindOfClass:[self class]]) {
		ZGarageSaleModel *model2 = (ZGarageSaleModel *)object;
		return [self.ID isEqual:model2.ID];
	}
	return NO;
}

@end

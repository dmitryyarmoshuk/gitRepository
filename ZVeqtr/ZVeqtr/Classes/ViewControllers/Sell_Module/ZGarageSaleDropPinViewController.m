//
//  ZGarageSaleDropPinViewController.m
//  ZVeqtr
//
//  Created by Maxim on 4/4/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZGarageSaleDropPinViewController.h"
//#import "SettingsViewController.h"
#import "NSDictionary+ZVeqtr.h"

//Leonid's:
#import "ASIFormDataRequest.h"
#import "ZPersonModel.h"
#import "ZMailDataModel.h"
#import "ZLocationModel.h"
#import "ZTaggedButton.h"
#import "ZPersonProfileVC.h"
#import "ZGarageSaleDropPinViewController.h"

//
#import "ZCommonRequest.h"
#import "ZCommentsListVC.h"
#import "ZNewMessageModel.h"
//
#import "SBJson.h"
#import "ZGeoplaceSelViewController.h"
#import "ZVeqtrAnnotation.h"
#import "ZUserModel.h"
#import "ZProductSalePreviewViewController.h"

#import "ZGarageSaleModel.h"

#import "DDAnnotationView.h"
#import "DDAnnotation.h"

@interface ZGarageSaleDropPinViewController ()

//	outlets

@property (nonatomic, retain) IBOutlet MKMapView		*mapView;
@property (nonatomic, retain) IBOutlet UIToolbar        *toolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem  *dropPinButton;


@property (nonatomic, retain) DDAnnotation *gpsAnnotation;

@end

@implementation ZGarageSaleDropPinViewController

#pragma mark -

- (void)releaseOutlets
{
	[super releaseOutlets];
    
	self.mapView = nil;
	self.gpsAnnotation = nil;
    self.toolbar = nil;
}

- (void)dealloc
{    
    self.delegate = nil;
    
	[super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self presentBackBarButtonItem];
    if(self.saleModel)
    {
        self.title = @"Preview";
    }
    else
    {
        [self presentSaveBarButtonItem];
        self.title = @"Location";
    }

    [self updateMap];
	
	self.gpsAnnotation = nil;
    
    if(self.saleModel)
    {
        if(self.saleModel.locationCoordinate)
            [_mapView addAnnotation:self.saleModel];
        else
            NSLog(@"No Coordinates");
        
        self.toolbar.hidden = YES;
        self.mapView.frame = self.view.bounds;
    }
    else
    {
        self.toolbar.hidden = NO;
        if(self.location)
        {
            self.dropPinButton.title = @"Remove Pin";
            self.gpsAnnotation = [[[DDAnnotation alloc] initWithCoordinate:self.location.coordinate addressDictionary:nil] autorelease];
            self.gpsAnnotation.title = [NSString	stringWithFormat:@"%f %f", self.location.coordinate.latitude, self.location.coordinate.longitude];
            [_mapView addAnnotation:self.gpsAnnotation];
        }
        else
        {
            self.dropPinButton.title = @"Drop Pin";
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self.navigationController setNavigationBarHidden:NO animated:YES];
    self.mapView.showsUserLocation = APP_DLG.currentUser.currentLocationVisible;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
    
    self.mapView.showsUserLocation = self.userModel.currentLocationVisible;
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

#pragma mark - Events

- (IBAction)actSave
{
	if(self.delegate)
    {
        CLLocation *location = nil;
        if(self.gpsAnnotation)
        {
            location = [[CLLocation alloc] initWithLatitude:self.gpsAnnotation.coordinate.latitude longitude:self.gpsAnnotation.coordinate.longitude];
        }
        
        [self.delegate controller:self didSelectLocation:location];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actDropPin
{
	if (self.gpsAnnotation)
    {
        self.dropPinButton.title = @"Drop Pin";
		[_mapView removeAnnotation:self.gpsAnnotation];
		self.gpsAnnotation = nil;
	}
	else
    {
        self.dropPinButton.title = @"Remove Pin";
		self.gpsAnnotation = [[[DDAnnotation alloc] initWithCoordinate:_mapView.region.center addressDictionary:nil] autorelease];
        self.gpsAnnotation.title = [NSString	stringWithFormat:@"%f %f", _mapView.region.center.latitude, _mapView.region.center.longitude];
		[_mapView addAnnotation:self.gpsAnnotation];
	}
}

-(IBAction)actOpenSale:(ZTaggedButton *)button
{
    ZProductSalePreviewViewController *ctrl = [ZProductSalePreviewViewController controller];
    ctrl.garageSaleModel = self.saleModel;
    [self.navigationController pushViewController:ctrl animated:YES];
}

- (IBAction)tap_Action:(UIGestureRecognizer *)recognizer
{
    self.userModel.currentLocationVisible = !self.userModel.currentLocationVisible;
    [self.userModel saveUser];
    
    self.mapView.showsUserLocation = self.userModel.currentLocationVisible;
}

#pragma mark - Services

- (void)updateMap
{
    if(self.saleModel)
    {
        MKCoordinateRegion region;
        region.center = self.saleModel.locationCoordinate.coordinate;
        MKCoordinateSpan span = {0.2, 0.2};
        region.span = span;
        [_mapView setRegion:region animated:NO];
    }
    else if(self.location)
    {
        MKCoordinateRegion region;
        region.center = self.location.coordinate;
        MKCoordinateSpan span = {0.2, 0.2};
        region.span = span;
        [_mapView setRegion:region animated:NO];
    }
	else if (APP_DLG.latitude < 360 && APP_DLG.longitude < 360)
    {
        MKCoordinateRegion region;
        CLLocationCoordinate2D coordinate;
        
        coordinate.latitude = APP_DLG.latitude;
        coordinate.longitude = APP_DLG.longitude;
        region.center = coordinate;
        MKCoordinateSpan span = {0.2, 0.2};
        region.span = span;
        [_mapView setRegion:region animated:NO];
    }
}

#pragma mark - MKMapView Annotations

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
	
	if (oldState == MKAnnotationViewDragStateDragging) {
		DDAnnotation *annotation = (DDAnnotation *)annotationView.annotation;
		annotation.title = [NSString	stringWithFormat:@"%f %f", annotation.coordinate.latitude, annotation.coordinate.longitude];
	}
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
	}
    
	if (annotation == self.gpsAnnotation)
    {
        static NSString* kPinAnnotationIdentifier = @"GPSAnnotationIdentifier";
        MKPinAnnotationView* pinView = (MKPinAnnotationView *)[_mapView dequeueReusableAnnotationViewWithIdentifier:kPinAnnotationIdentifier];
        if (!pinView)
        {
            //if an existing pin view was not available, create one
            DDAnnotationView *draggablePinView = [DDAnnotationView annotationViewWithAnnotation:annotation reuseIdentifier:kPinAnnotationIdentifier mapView:self.mapView];
            draggablePinView.animatesDrop = YES;
            
            return draggablePinView;
        }
        else
        {
            pinView.annotation = annotation;
        }
        
        return pinView;
    }
    
    if ([annotation isMemberOfClass:[ZGarageSaleModel class]])
    {
		ZGarageSaleModel *model = (ZGarageSaleModel *)annotation;
        
		return [model annotationViewForMap:_mapView target:self action:@selector(actOpenSale:)];
	}
	
    return nil;
}

#pragma mark - NewMessageViewControllerDelegate

- (ZUserModel *)userModel
{
	return APP_DLG.currentUser;
}

@end

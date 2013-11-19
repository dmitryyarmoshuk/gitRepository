//
//  ZPersonalMessageViewController.m
//  ZVeqtr
//
//  Created by Maxim on 3/8/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZPersonalMessageViewController.h"

//#import "SettingsViewController.h"
#import "NSDictionary+ZVeqtr.h"
//Leonid's:
#import "ASIFormDataRequest.h"
#import "ZPersonModel.h"
#import "ZMailDataModel.h"
#import "ZLocationModel.h"
#import "ZTaggedButton.h"
#import "ZPersonProfileVC.h"
//
#import "ZCommonRequest.h"
#import "ZCommentsListVC.h"
#import "ZNewMessageModel.h"
//
#import "SBJson.h"
#import "ZGeoplaceSelViewController.h"
#import "ZVeqtrAnnotation.h"
#import "ZUserModel.h"
#import "DDAnnotationView.h"
#import "DDAnnotation.h"


typedef enum {
	SearchForLocationZip,
	SearchForUser,
	SearchForHashtag,
} SearchFor;

@interface ZPersonalMessageViewController ()
//	outlets

@property (nonatomic, retain) IBOutlet MKMapView		*mapView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem	*buttonMail;
@property (nonatomic, retain) IBOutlet UIBarButtonItem	*buttonText;

@property (nonatomic, retain) DDAnnotation *gpsAnnotation;

@end

@implementation ZPersonalMessageViewController

#pragma mark -

- (void)releaseOutlets
{
	[super releaseOutlets];
	self.mapView = nil;
	self.buttonMail = nil;
	self.buttonText = nil;
	self.gpsAnnotation = nil;
}

- (void)dealloc {
    
    self.userModel = nil;
    self.personModel = nil;
    self.previousController = nil;
    
	[super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Personal Message";
    
    [self presentBackBarButtonItem];
	
	updatedPosition = NO;
	
	self.gpsAnnotation = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self.navigationController setNavigationBarHidden:NO animated:YES];
    self.mapView.showsUserLocation = self.userModel.currentLocationVisible;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if ([APP_DLG didUserLogin]) {
		[self performSelector:@selector(updateMap) withObject:nil afterDelay:1];
	}
	
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

#pragma mark - Actions

- (IBAction)actMail {
	
	[self.view endEditing:YES];
	
	if (self.gpsAnnotation) {
		
		[_mapView removeAnnotation:self.gpsAnnotation];
		self.gpsAnnotation = nil;
        
		_buttonText.enabled = NO;
	}
	else
    {
        self.gpsAnnotation = [[[DDAnnotation alloc] initWithCoordinate:_mapView.region.center addressDictionary:nil] autorelease];
        self.gpsAnnotation.title = @"Drag to Move Pin";
        self.gpsAnnotation.subtitle = [NSString	stringWithFormat:@"%f %f", _mapView.region.center.latitude, _mapView.region.center.longitude];
        
		//self.gpsAnnotation = [[MKPointAnnotation new] autorelease];
		//self.gpsAnnotation.coordinate = _mapView.region.center;
		[_mapView addAnnotation:self.gpsAnnotation];
		_buttonText.enabled = YES;
	}
}

- (IBAction)actText
{
	NewMessageViewController *controller = [NewMessageViewController controller];
	controller.delegate = self;
    controller.isDirectMessage = YES;
	[self.navigationController pushViewController:controller animated:YES];
}

-(void)showPinOnCoordinate:(CLLocationCoordinate2D)coordinate
{
    _userCoordinateMode = YES;
    _coordinate = coordinate;
    
    self.gpsAnnotation = [[[DDAnnotation alloc] initWithCoordinate:coordinate addressDictionary:nil] autorelease];
    self.gpsAnnotation.title = @"Drag to Move Pin";
    self.gpsAnnotation.subtitle = [NSString	stringWithFormat:@"%f %f", _mapView.region.center.latitude, _mapView.region.center.longitude];
    
    [_mapView addAnnotation:self.gpsAnnotation];
    
    updatedPosition = NO;
    [self updateMap];
    
    self.buttonMail.enabled = NO;
    self.buttonText.enabled = YES;
}

#pragma mark - Services

- (void)updateMap
{
	if (!updatedPosition) {
		if (APP_DLG.latitude < 360 && APP_DLG.longitude < 360) {
			MKCoordinateRegion region;
    
            if(!_userCoordinateMode)
			{
                _coordinate.latitude = APP_DLG.latitude;
                _coordinate.longitude = APP_DLG.longitude;
			}
            
            region.center = _coordinate;
			MKCoordinateSpan span = {0.2, 0.2};
			region.span = span;
			[_mapView setRegion:region animated:NO];
			
			updatedPosition = YES;
		}
	}
	
	//[self updateHomeAnnotationIfChangedCoord:CLLocationCoordinate2DMake(APP_DLG.latitude, APP_DLG.longitude)];
}

#pragma mark - Map actions

- (void)showAnnotationHome:(ZTaggedButton *)button {
	LLog(@"%@", button);
    
    /*
     ZThisUserProfileVC *ctr = [ZThisUserProfileVC controller];
     ctr.userModel = self.userModel;
     ctr.delegate = self;
     [self.navigationController pushViewController:ctr animated:YES];
     */
    
	ZPersonProfileVC *ctr = [ZPersonProfileVC controller];
	ctr.userModel = self.userModel;
	[self.navigationController pushViewController:ctr animated:YES];
}

- (void)showAnnotationPing:(ZTaggedButton *)button {
	
	LLog(@"%@", button);
	
	ZPersonModel *personModel = button.userInfo;
	ZPersonProfileVC *ctr = [ZPersonProfileVC controller];
	ctr.personModel = personModel;
	[self.navigationController pushViewController:ctr animated:YES];
}

- (IBAction)tap_Action:(UIGestureRecognizer *)recognizer
{
    self.userModel.currentLocationVisible = !self.userModel.currentLocationVisible;
    [self.userModel saveUser];
    
    self.mapView.showsUserLocation = self.userModel.currentLocationVisible;
}

#pragma mark - MKMapView Annotations

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{	
	if (oldState == MKAnnotationViewDragStateDragging)
    {
		DDAnnotation *annotation = (DDAnnotation *)annotationView.annotation;
		annotation.subtitle = [NSString	stringWithFormat:@"%f %f", annotation.coordinate.latitude, annotation.coordinate.longitude];
	}
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation {
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
	}
	
	if (annotation == self.gpsAnnotation) {
        static NSString* kPinAnnotationIdentifier = @"GPSAnnotationIdentifier";
        MKPinAnnotationView* pinView = (MKPinAnnotationView *)[_mapView dequeueReusableAnnotationViewWithIdentifier:kPinAnnotationIdentifier];
        if (!pinView)
        {
            DDAnnotationView *draggablePinView = [DDAnnotationView annotationViewWithAnnotation:annotation reuseIdentifier:kPinAnnotationIdentifier mapView:self.mapView];
            draggablePinView.animatesDrop = YES;
            
            return draggablePinView;
            // if an existing pin view was not available, create one
            /*
            MKPinAnnotationView* customPinView = [[[MKPinAnnotationView alloc]
												   initWithAnnotation:annotation reuseIdentifier:ID] autorelease];
			
			
			customPinView.pinColor = MKPinAnnotationColorRed;
            customPinView.animatesDrop = YES;
			customPinView.draggable = YES;
			
            return customPinView;
             */
        }
        else
        {
            pinView.annotation = annotation;
        }
        
        return pinView;
    }
	
    return nil;
}

#pragma mark - NewMessageViewControllerDelegate

- (void)newMessageViewController:(NewMessageViewController *)newMessageViewController
	didFinishWithNewMessageModel:(ZNewMessageModel *)model {
	
	[self.navigationController popToViewController:self.previousController animated:YES];
	
	//	send this new message
	
	if (self.gpsAnnotation && [model isValid]) {
		
		model.sLatitude  = [NSString stringWithFormat:@"%f", self.gpsAnnotation.coordinate.latitude];
		model.sLongitude = [NSString stringWithFormat:@"%f", self.gpsAnnotation.coordinate.longitude];
		
		ZCommonRequest *request = [ZCommonRequest requestWithNewMessageModel:model];
		[request setPostValue:self.personModel.ID forKey:@"to_user"];
        
		[super showProgress];
		dispatch_async(dispatch_queue_create("request.message.create", NULL), ^{
			[request startSynchronous];
			LLog(@"============== mail id '%@'", [request responseString]);
			LLog(@"response:'%@' (err:'%@')", [request responseString], request.error);
            
			if (request.error) {
				NSString *msg = request.error.localizedDescription;
                
				dispatch_async(dispatch_get_main_queue(), ^{
					LLog(@"%@", request.error.localizedDescription);
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
					[alert show];
					[alert release];
				});
			}
			else {
				dispatch_async(dispatch_get_main_queue(), ^{
					[super hideProgress];
					if (self.gpsAnnotation) {
						[_mapView removeAnnotation:self.gpsAnnotation];
						self.gpsAnnotation = nil;
					}
					[self updateMap];
				});
			}
		});
	}
}

- (void)newMessageViewControllerDidCancel:(NewMessageViewController *)newMessageViewController
{
	[self.navigationController popToViewController:self animated:YES];
}

#pragma mark -

- (ZUserModel *)userModel {
	return APP_DLG.currentUser;
}

- (void)invalidateMap {
	if (self.navigationController.visibleViewController == self) {
		[self updateMap];
	}
}

@end

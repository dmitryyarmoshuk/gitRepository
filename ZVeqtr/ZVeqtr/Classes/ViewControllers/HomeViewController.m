//
//  HomeViewController.m
//  Peek
//
//  Created by Pavel on 14.06.11.
//  Copyright 2011 Horns & Hoofs. All rights reserved.
//

#import "HomeViewController.h"
//#import "SettingsViewController.h"
#import "NSDictionary+ZVeqtr.h"
#import "RegisterViewController.h"
#import "TimeFilterViewController.h"
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
//	to replace this SettingsViewController.h
#import "ZThisUserProfileVC.h"
#import "ZUserModel.h"

#import "ZAddFavoriteViewController.h"
#import "ZFavoriteFilterModel.h"
#import "ZFavoriteFilterModel.h"
#import "ZCurrentSalesViewController.h"
#import "ZNCCategoriesVC.h"

#import "ZGarageSaleModel.h"

#import "CustomBadge.h"

#import "ZProductSalePreviewViewController.h"
#import "ZUserInfoButton.h"
#import "ZGarageSaleModel.h"

#import "Foursquare2.h"
#import "FSVenue.h"
#import "FSConverter.h"
#import "ZVenueModel.h"
#import "ZVenueConversationListVC.h"
#import "ZConversationModel.h"
#import "ZVenueConversationVC.h"


typedef enum {
	SearchForLocationZip,
	SearchForHashtag,
    SearchForUser,
} SearchFor;

@interface HomeViewController ()
<ZThisUserProfileVCDelegate>
//	outlets
@property (nonatomic, retain) IBOutlet UISearchBar		*searchBar;
@property (nonatomic, retain) IBOutlet MKMapView		*mapView;
@property (nonatomic, retain) IBOutlet UIToolbar		*friendsOnlyBar;
@property (nonatomic, retain) IBOutlet UISwitch			*friendsOnlySwitch;
@property (nonatomic, retain) IBOutlet UIBarButtonItem	*buttonMail;
@property (nonatomic, retain) IBOutlet UIBarButtonItem	*buttonText;
@property (nonatomic, retain) IBOutlet UILabel			*labFriendsOnly;
@property (nonatomic, retain) IBOutlet CustomBadge      *customBadgeMessageCenter;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView	*searchSpinner;
@property (nonatomic, retain) IBOutlet UIView					*searchProgressView;
//
@property (nonatomic, retain) NSMutableArray *allPersonModels;
@property (nonatomic, retain) NSMutableArray *allMailModels;
@property (nonatomic, retain) NSMutableArray *allSalesModels;

@property (nonatomic, retain) NSMutableArray *nearbyVenues;
@property (nonatomic, retain) NSMutableArray *nearbyVenues2;

@property (nonatomic, retain) HashBookmarksVC *hashBookmarksVC;
@property (nonatomic, assign) BOOL isMapValid;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;
@property (nonatomic, retain) MKPointAnnotation	*homeAnnotation;

@property (nonatomic, retain) NSMutableDictionary	*dicSearchStrings;

@property (nonatomic, assign) BOOL		mapWantsMoving;
@property (nonatomic, retain) MKPointAnnotation *gpsAnnotation;

//flag is set, when we need to show search results and "add to favorites" (star) button
@property (nonatomic, assign) BOOL		isSearchResultsState;
@property (nonatomic, copy)   NSString  *searchStr;
@property (nonatomic, assign) BOOL changeVenues;

//standard bookmark icon
@property (nonatomic, retain) UIImage *searchBarBookmarkIcon;

@end

@interface HomeViewController (ZipCode_Timer)
<ZGeoplaceSelViewControllerDelegate>
@end


@implementation HomeViewController {
	NSTimer	*_updateTimer;
}

#pragma mark -

- (void)releaseOutlets
{
	[super releaseOutlets];
	self.searchBar = nil;
	self.mapView = nil;
	self.friendsOnlyBar = nil;
	self.friendsOnlySwitch = nil;
	self.buttonMail = nil;
	self.buttonText = nil;
	self.labFriendsOnly = nil;
	self.homeAnnotation = nil;
	self.gpsAnnotation = nil;
    self.customBadgeMessageCenter = nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
	self.allPersonModels = nil;
	self.allMailModels = nil;
    self.allSalesModels = nil;
	self.hashBookmarksVC = nil;
	self.dateFormatter = nil;
	self.dicSearchStrings = nil;
    self.searchBarBookmarkIcon = nil;
    
	[super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.title = @"Home";
    
    [self.searchBar setBackgroundImage:[UIImage imageNamed:@"bar-top-navigation.png"]];
    
    self.searchBarBookmarkIcon = [self.searchBar imageForSearchBarIcon:UISearchBarIconBookmark state:UIControlStateNormal];
    
    //self.searchBar.showsBookmarkButton = NO;
	
	[self hideSearchProgress];
	_friendsOnlyBar.hidden = YES;

	[super presentEmptyBackBarButtonItem];
	
	UIFont *font = [UIFont fontWithName:@"RBNo3.1-Black" size:16];
	if (font)
    {
		self.labFriendsOnly.font = font;
	}
	
	if (!_dateFormatter)
    {
		_dateFormatter = [NSDateFormatter new];
		//_dateFormatter.locale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease];
		_dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
		[_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm':00' '+00:00"];
	}
	if (!self.dicSearchStrings)
    {
		self.dicSearchStrings = [NSMutableDictionary dictionaryWithCapacity:4];
	}
	
	updatedPosition = NO;
	
	_friendsOnlySwitch.on = self.userModel.friendsOnlySearch;
	
	self.gpsAnnotation = nil;
    
    [self.customBadgeMessageCenter autoBadgeSizeWithString:@"3"];
}

- (void)updateNotificationBadge
{
    if(self.userModel.unreadNotificationsCount > 0)
    {
        self.customBadgeMessageCenter.hidden = NO;
        
        NSString *count = [NSString stringWithFormat:@"%d", self.userModel.unreadNotificationsCount];
        
        [self.customBadgeMessageCenter autoBadgeSizeWithString:count];
    }
    else
    {
        self.customBadgeMessageCenter.hidden = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if (!self.navigationController.navigationBarHidden) {
		[self.navigationController setNavigationBarHidden:YES animated:YES];
	}
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(requestUnreadNotifications)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    self.mapView.showsUserLocation = self.userModel.currentLocationVisible;
    [self updateNotificationBadge];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self checkIfLoginValid];
	
	if (!self.isMapValid && [APP_DLG didUserLogin])
    {
		[self performSelector:@selector(updateMap) withObject:nil afterDelay:1];
	}
	
	_updateTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(tickUpdateTimer:) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
    _visibleAnnotation = nil;
    
	[_updateTimer invalidate];
	_updateTimer = nil;
}

#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

-(BOOL)shouldAutorotate
{
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark -

- (void)checkIfLoginValid
{	
	if (self.userModel.sessionID.length == 0)
    {
		self.isMapValid = NO;
		RegisterViewController *controller = [RegisterViewController controller];
		[self presentModalViewController:controller animated:YES];
	}
}

#pragma mark -

-(void)updateBookmarkIcon
{
    if(self.isSearchResultsState)
    {
        [self.searchBar setImage:[UIImage imageNamed: @"icon_star3"] forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateNormal];
    }
    else
    {
        [self.searchBar setImage:self.searchBarBookmarkIcon forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateNormal];
    }
}

-(NSString*)currentFilterTypeForSearchText:(NSString*)searchText
{
    NSString *firstChar = [searchText substringToIndex:1];
    if([firstChar isEqualToString:@"#"])
    {
        //hashtag search
        return FILTER_TYPE_HASHTAG;
    }
    else if([firstChar isEqualToString:@"@"])
    {
        //user search
        return FILTER_TYPE_USER;
    }
    else
    {
        //lcoation search
        return FILTER_TYPE_LOCATION;
    }
    
    NSInteger selectedScope = self.searchBar.selectedScopeButtonIndex;
    if(selectedScope == 0)
        return FILTER_TYPE_LOCATION;
    else if(selectedScope == 1)
        return FILTER_TYPE_HASHTAG;
    
    return FILTER_TYPE_USER;
}

-(void)doSearchWithText:(NSString*)searchText timeFilter:(NSDictionary*)timeFilter
{
    NSMutableDictionary *args = [NSMutableDictionary dictionaryWithCapacity:16];
	searchText = [searchText trimWhitespace];
    
	if (searchText.length == 0)
    {
		return;
	}
    
    NSString *firstChar = [searchText substringToIndex:1];
    if([firstChar isEqualToString:@"#"])
    {
        if (self.allMailModels.count)
        {
            [self.mapView removeAnnotations:self.allMailModels];
        }
        
        //hashtag search
        NSArray *arrHashtags = [searchText extractHashtags];
        
        if (arrHashtags.count)
        {
            [self.userModel addHashtagsFromArray:arrHashtags];
            args[@"find"] = [arrHashtags componentsJoinedByString:@" "];
            
            [self requestMailWithArguments:args timeFilter:timeFilter showResults:NO];
            [self requestSalesWithTag:[searchText substringFromIndex:1]];
            [self getVenuesForLocation:CLLocationCoordinate2DMake(APP_DLG.latitude, APP_DLG.longitude) query:searchText];
        }
        else
        {
            [APP_DLG showAlertWithMessage:@"Can't extract hashtag. Please, try again." title:nil];
        }
    }
    else if([firstChar isEqualToString:@"@"])
    {
        //user search
        //args[@"user"] = searchText;
        //args[@"word"] = searchText;
        //[self requestPersonsWithArguments:args showResults:NO];
        args[@"by_user_name"] = [searchText substringFromIndex:1];
        if (self.allMailModels.count)
        {
            [self.mapView removeAnnotations:self.allMailModels];
        }
        
        [self requestMailWithArguments:args timeFilter:timeFilter showResults:NO];
    }
    else
    {
        //lcoation search
        [self requestGeocodeWithSearchString:searchText];
    }
}

#pragma mark - UISearchBar

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
	[_searchBar setShowsCancelButton:YES animated:YES];
    self.isSearchResultsState = NO;
    
    [self updateBookmarkIcon];
    
	_friendsOnlyBar.hidden = NO;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
	/*
	NSInteger selectedScope = self.searchBar.selectedScopeButtonIndex;
	self.dicSearchStrings[@(selectedScope)] = [self.searchBar.text trimWhitespace];
	*/
    
	[_searchBar setShowsCancelButton:NO animated:YES];
    
	_friendsOnlyBar.hidden = YES;
	
	self.userModel.friendsOnlySearch = _friendsOnlySwitch.on;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	_searchBar.text = nil; //zs
	[_searchBar resignFirstResponder];
    
    self.isSearchResultsState = NO;
    [self updateBookmarkIcon];
    
    self.searchStr = nil;
    if(self.nearbyVenues.count > 0) {
        [self.mapView removeAnnotations:self.nearbyVenues];
    }
    self.nearbyVenues = nil;

	[self updateMap];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[_searchBar resignFirstResponder];
    
    self.searchStr = searchBar.text; //zs
    if ([self.searchStr hasPrefix:@"#"]) {
        if(self.nearbyVenues.count > 0) {
            [self.mapView removeAnnotations:self.nearbyVenues];
        }
        self.nearbyVenues = nil;
    }
    self.changeVenues = YES;
    
    self.isSearchResultsState = YES;
    [self updateBookmarkIcon];
	
    NSDictionary *timefilter = [self.userModel dateFilterArguments];
    
	[self doSearchWithText:searchBar.text timeFilter:timefilter];
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar
{
    if(self.isSearchResultsState)
    {
        MKMapRect visibleMapRect = self.mapView.visibleMapRect;
        NSMutableDictionary *mapRectDic = [NSMutableDictionary dictionary];
        [mapRectDic setObject:[NSNumber numberWithDouble:visibleMapRect.origin.x] forKey:@"x"];
        [mapRectDic setObject:[NSNumber numberWithDouble:visibleMapRect.origin.y] forKey:@"y"];
        [mapRectDic setObject:[NSNumber numberWithDouble:visibleMapRect.size.width] forKey:@"width"];
        [mapRectDic setObject:[NSNumber numberWithDouble:visibleMapRect.size.height] forKey:@"height"];
        
        ZAddFavoriteViewController *ctr = [ZAddFavoriteViewController controller];
        ctr.filterName = searchBar.text;
        ctr.filterType = [self currentFilterTypeForSearchText:searchBar.text];
        ctr.selectedZipPlace = mapRectDic;
        
        [self.navigationController pushViewController:ctr animated:YES];
        
        self.isSearchResultsState = NO;
        [self updateBookmarkIcon];
        
        return;
    }
    
	[_searchBar resignFirstResponder];
	
    
	if ([HashBookmarksVC hasBookmarks]) {
		HashBookmarksVC *ctr = [HashBookmarksVC controller];
		ctr.allDisabledHashtags = [self.searchBar.text extractHashtags];
		ctr.delegate = self;
		self.hashBookmarksVC = ctr;
		[self presentModalViewController:ctr animated:YES];
	}
	else
    {
        [APP_DLG showAlertWithMessage:@"No Hashtags yet" title:nil];
	}
}

/*
- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
	self.searchBar.text = self.dicSearchStrings[@(selectedScope)];
}
*/

#pragma mark - HashBookmarksVC

- (void)hashBookmarksVC:(HashBookmarksVC *)hashBookmarksVC didSelectTagString:(NSString *)tagString
{
	NSString *str = _searchBar.text;
	str = [str stringByAppendingFormat:@" %@", tagString];
	_searchBar.text = str;
	
	[self.hashBookmarksVC dismissModalViewControllerAnimated:YES];
	self.hashBookmarksVC = nil;
}

#pragma mark - UIActionSheet

enum {
	kSheetActUpdateMap,
	kSheetActLogout,
	kSheetActAddFavoriteLoc,
    kSheetActGarageSale
};

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	
	LLog(@"%d", buttonIndex);
	
	switch (buttonIndex) {
		case kSheetActUpdateMap: {
			//	update map
			self.mapWantsMoving = YES;
			[self updateMap];
			break;
		}
			
		case kSheetActLogout: {
			//	logout
            [self doLogout:YES];
			
			break;
		}
			
		case kSheetActAddFavoriteLoc:
        {
			//	add favorite loc
            ZFavoritesListViewController *ctrl = [ZFavoritesListViewController controller];
            ctrl.delegate = self;
            [self.navigationController pushViewController:ctrl animated:YES];
            
            /*
			if (self.gpsAnnotation) {
				ZLocationModel *locModel = [[ZLocationModel new] autorelease];
				locModel.coordinate = self.gpsAnnotation.coordinate;
				locModel.title = @"gps coord title";
				[self.userModel addFavoriteLocationModel:locModel];
				
				break;
			}
             */
		}
            break;
        case kSheetActGarageSale:
        {
            ZCurrentSalesViewController *ctrl = [ZCurrentSalesViewController controller];
            [self.navigationController pushViewController:ctrl animated:YES];            
        }
            break;
			
		default:
			break;
	}//sw
}

#pragma mark - Actions

- (IBAction)actMessageCenter
{
    ZNCCategoriesVC *ctrl = [ZNCCategoriesVC controller];
  /*
    UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:ctrl] autorelease];
    [self.navigationController presentModalViewController:navController animated:YES];
*/
    [self.navigationController pushViewController:ctrl animated:YES];
}

- (IBAction)actTimefilter
{
	[self.view endEditing:YES];
	
    TimeFilterViewController *ctr = [TimeFilterViewController controller];
	ctr.userModel = self.userModel;
	[self.navigationController pushViewController:ctr animated:YES];
}

- (IBAction)actGotoSettings
{

	[self.view endEditing:YES];
	
//	user's profile in fact
//	SettingsViewController *ctr = [SettingsViewController controller];
	ZThisUserProfileVC *ctr = [ZThisUserProfileVC controller];
	ctr.userModel = self.userModel;
	ctr.delegate = self;
	[self.navigationController pushViewController:ctr animated:YES];
}

- (IBAction)actionMenuSheet:(UIBarButtonItem *)button
{
	[self.view endEditing:YES];

	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Action"
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:nil
													otherButtonTitles:@"Update Map", @"Logout", @"Favorite Locations Section", @"Sales", nil];
    
	[actionSheet showFromBarButtonItem:button animated:YES];
	[actionSheet release];
}

- (IBAction)actMail
{
	
	[self.view endEditing:YES];
	
	if (self.gpsAnnotation) {
		
		[_mapView removeAnnotation:self.gpsAnnotation];
		self.gpsAnnotation = nil;

		_buttonText.enabled = NO;
	}
	else {
		
		self.gpsAnnotation = [[MKPointAnnotation new] autorelease];
		self.gpsAnnotation.coordinate = _mapView.region.center;
		[_mapView addAnnotation:self.gpsAnnotation];
		_buttonText.enabled = YES;
	}
}

- (IBAction)actText
{
	NewMessageViewController *controller = [NewMessageViewController controller];
	controller.delegate = self;
	[self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)tap_Action:(UIGestureRecognizer *)recognizer
{
    self.userModel.currentLocationVisible = !self.userModel.currentLocationVisible;
    [self.userModel saveUser];
    
    self.mapView.showsUserLocation = self.userModel.currentLocationVisible;
}

-(void)doLogout:(BOOL)shouldSendRequest
{
    if(shouldSendRequest)
    {
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL urlWithActionString:@"auth"]];
        [request setPostValue:@"logout" forKey:@"action"];
        [request setPostValue:self.userModel.sessionID forKey:@"sess_id"];
        
        [request startSynchronous];
        
        NSString *responseStr = [request responseString];
        NSDictionary *resultDic = [NSDictionary dictionaryWithResponseString:responseStr];
        LLog(@"LOGOUT: %@, msg:%@\nresponse:%@", resultDic, resultDic[@"msg"], responseStr);
    }

    //	reset time filters for the next user
    [self.userModel resetTimeFilters];
    [self.userModel saveDateComponents];
    APP_DLG.currentUser = nil;
    
    RegisterViewController *controller = [RegisterViewController controller];
    [self presentModalViewController:controller animated:YES];
}

-(void)showConversationOnMap:(ZMailDataModel*)mailModel
{
    [self.navigationController popToViewController:self animated:YES];
    BOOL isFound = NO;
    for(ZMailDataModel *model in self.allMailModels)
    {
        if([model.ID isEqualToString:mailModel.ID])
        {
            isFound = YES;
            [self.mapView setCenterCoordinate:model.coordinate animated:YES];
            break;
        }
    }
    
    if(!isFound)
    {
        [self requestConversationWithId:mailModel.ID showOnMap:YES];
    }
}

-(void)showVenueOnMap:(ZVenueModel*)venueModel
{
    [self.navigationController popToViewController:self animated:YES];
    BOOL isFound = NO;
    for(ZVenueModel *model in self.nearbyVenues)
    {
        if([model.ID isEqualToString:venueModel.ID])
        {
            isFound = YES;
            [self.mapView setCenterCoordinate:model.coordinate animated:YES];
            break;
        }
    }
    
    if(!isFound)
    {
        [self requestVenueWithId:venueModel.ID showOnMap:YES];
    }
}

-(void)showSaleOnMap:(ZGarageSaleModel*)saleModel
{
    [self.navigationController popToViewController:self animated:YES];
    BOOL isFound = NO;
    for(ZGarageSaleModel *model in self.allSalesModels)
    {
        if([model.ID isEqualToString:saleModel.ID])
        {
            isFound = YES;
            [self.mapView setCenterCoordinate:model.coordinate animated:YES];
            break;
        }
    }
    
    if(!isFound)
    {
        [self requestSaleWithId:saleModel.ID showOnMap:YES];
    }
}

#pragma mark - Services

- (void)showSearchProgress
{
    NSLog(@"%@", NSStringFromCGRect(self.searchBar.frame));
	self.searchProgressView.frame = self.searchBar.frame;
	self.searchProgressView.hidden = NO;
	[self.searchSpinner startAnimating];
}

- (void)hideSearchProgress
{
	[self.searchSpinner stopAnimating];
	self.searchProgressView.hidden = YES;
}

- (void)updateMap
{
	_buttonText.enabled = NO;
    NSLog(@"update_map1");
	
	if (!updatedPosition)
    {
		if (APP_DLG.latitude < 360 && APP_DLG.longitude < 360)
        {
			MKCoordinateRegion region;
			CLLocationCoordinate2D coordinate;
			
			coordinate.latitude = APP_DLG.latitude;
			coordinate.longitude = APP_DLG.longitude;
			region.center = coordinate;
			MKCoordinateSpan span = {0.2, 0.2};
			region.span = span;
            
//          region = MKCoordinateRegionMakeWithDistance(coordinate, 500, 500);
            
			[_mapView setRegion:region animated:NO];
			
			updatedPosition = YES;
		}
	}
	
	[self updateHomeAnnotationIfChangedCoord:CLLocationCoordinate2DMake(APP_DLG.latitude, APP_DLG.longitude)];
	
    if(!self.isSearchResultsState)
    {
        NSLog(@"update_map2");
        NSDictionary *timefilter = [self.userModel dateFilterArguments];
        //[self requestMailWithArguments:nil showResults:NO];
        [self requestMailWithArguments:nil timeFilter:timefilter showResults:NO];
        [self requestAllSales];
    }
    
    [self requestUnreadNotifications];
}

- (void)updateHomeAnnotationIfChangedCoord:(CLLocationCoordinate2D)newCoord
{
	if (self.homeAnnotation.coordinate.longitude == newCoord.longitude &&
		self.homeAnnotation.coordinate.latitude == newCoord.latitude)
	{
		//	no change
		return;
	}
	
	if (self.homeAnnotation) {
		[_mapView removeAnnotation:self.homeAnnotation];
	}

	MKPointAnnotation *newHomeAnnotation = [[MKPointAnnotation new] autorelease];
	newHomeAnnotation.coordinate = newCoord;
	newHomeAnnotation.title = self.userModel.username;
	newHomeAnnotation.subtitle = APP_DLG.homeSubtitle;
    self.homeAnnotation = newHomeAnnotation;
	[_mapView addAnnotation:newHomeAnnotation];
    
    [_mapView removeAnnotation:self.homeAnnotation];
}

- (void)showVenueConversationId:(NSString*)conversationId
{
    NSLog(@"Open venue conversation for ID=%@", conversationId);
    ZConversationModel *model = [ZConversationModel modelWithID:conversationId];
    
    ZVenueConversationVC *ctr = [ZVenueConversationVC controller];
    ctr.conversationModel = model;
    [self.navigationController pushViewController:ctr animated:YES];
}

- (void)showMailMessageWithId:(NSString*)mailModelId
{
    ZMailDataModel *model = nil;
    for(ZMailDataModel *mod in self.allMailModels)
    {
        if([mod.ID isEqualToString:mailModelId])
        {
            model = mod;
            break;
        }
    }
    
    if(!model)
        model = [ZMailDataModel modelWithID:mailModelId];
        
    [self showMailMessage:model];
}

- (void)showSailMessageWithId:(NSString*)sailId itemId:(NSString*)itemId
{
    /*
    ZSellModuleImageDescriptionViewController *ctrl = [ZSellModuleImageDescriptionViewController controller];
    ctrl.isEditing = NO;
    ctrl.imageModel = imageModel;
    [self.navigationController pushViewController:ctrl animated:YES];
     */
}

- (void)showMailMessage:(ZMailDataModel*)mailModel
{
    UIViewController *visibleController = [self.navigationController visibleViewController];
    if([visibleController isKindOfClass:[ZCommentsListVC class]])
    {
        ZCommentsListVC *commentCtrl = (ZCommentsListVC*)visibleController;
        if(![commentCtrl.mailModel.ID isEqualToString:mailModel.ID])
        {
             [self.navigationController popViewControllerAnimated:NO];
        }
    }
    else
    {
        ZCommentsListVC *ctr = [ZCommentsListVC controller];
        ctr.mailModel = mailModel;
        ctr.userModel = self.userModel;
        [self.navigationController pushViewController:ctr animated:YES];
    }
}

#pragma mark - Requests

- (void)requestConversationWithId:(NSString*)conversationId showOnMap:(BOOL)showOnMap
{
    [self showProgress];
    NSMutableDictionary *args = [NSMutableDictionary dictionary];
    
    [args setObject:conversationId forKey:@"get_ids"];
    
	ZCommonRequest *request = [ZCommonRequest requestWithActionName:@"place" arguments:args];
    
	dispatch_async(dispatch_queue_create("request.sale.get", NULL), ^{
		[request startSynchronous];
		
        if (request.error)
        {
            [APP_DLG showAlertWithMessage:request.error.localizedDescription title:@"Request error"];
            
            return;
        }
        
        NSString *responseString = [request responseString];
        NSLog(@"%@", responseString);
        NSArray *resultArr = [responseString JSONValue];
        
		dispatch_async(dispatch_get_main_queue(), ^{
            
                        [self hideProgress];
            
            if(!resultArr || resultArr.count == 0)
            {
                [APP_DLG showAlertWithMessage:[NSString stringWithFormat:@"Could not find the post with id=%@", conversationId] title:@"Ups.."];
                return;
            }
            
            if (self.allMailModels.count)
            {
                [self.mapView removeAnnotations:self.allMailModels];
            }
            
            for (NSDictionary *dic in resultArr)
            {
                ZMailDataModel *model = [ZMailDataModel mailDataModelWithDictionary:dic];
                _visibleAnnotation = model;
                
                if(!self.allMailModels)
                    self.allMailModels = [NSMutableArray array];
                
                [self.allMailModels addObject:model];
                
                if(showOnMap)
                    [self.mapView setCenterCoordinate:model.coordinate animated:YES];
                break;
            }
            
            if (self.allMailModels.count)
            {
                [self.mapView addAnnotations:self.allMailModels];
            }
            

            
		});
	});
}

- (void)requestSaleWithId:(NSString*)saleId showOnMap:(BOOL)showOnMap
{
    [self showProgress];
    NSMutableDictionary *args = [NSMutableDictionary dictionary];
    
    [args setObject:@"show" forKey:@"action"];
    [args setObject:saleId forKey:@"sale_id"];
    
	ZCommonRequest *request = [ZCommonRequest requestWithActionName:@"sale" arguments:args];
    
	dispatch_async(dispatch_queue_create("request.sale.get", NULL), ^{
		[request startSynchronous];
		
        if (request.error)
        {
            [APP_DLG showAlertWithMessage:request.error.localizedDescription title:@"Request error"];
            
            return;
        }
        
        NSString *responseString = [request responseString];
        NSLog(@"%@", responseString);
        NSArray *resultArr = [responseString JSONValue];
        
		dispatch_async(dispatch_get_main_queue(), ^{
            
            [self hideProgress];
            
            if(!resultArr || resultArr.count == 0)
            {
                [APP_DLG showAlertWithMessage:[NSString stringWithFormat:@"Could not find the sale with id=%@", saleId] title:@"Ups.."];
                return;
            }
            
            if (self.allSalesModels.count)
            {
                [self.mapView removeAnnotations:self.allMailModels];
            }
            
            for (NSDictionary *dic in resultArr)
            {
                ZGarageSaleModel *model = [ZGarageSaleModel modelWithDictionary:dic];
                _visibleAnnotation = model;
                
                if(!self.allSalesModels)
                    self.allSalesModels = [NSMutableArray array];
                
                [self.allSalesModels addObject:model];
                
                if(showOnMap)
                    [self.mapView setCenterCoordinate:model.coordinate animated:YES];
                break;
            }
            
            if (self.allSalesModels.count)
            {
                [self.mapView addAnnotations:self.allSalesModels];
            }
            
		});
	});
}

- (void)requestVenueWithId:(NSString*)conversationId showOnMap:(BOOL)showOnMap
{
    [self showProgress];
    NSMutableDictionary *args = [NSMutableDictionary dictionary];
    
    [args setObject:@"get_venue_info" forKey:@"action"];
    [args setObject:conversationId forKey:@"convers_id"];
    
	ZCommonRequest *request = [ZCommonRequest requestWithActionName:@"venues" arguments:args];
    
	dispatch_async(dispatch_queue_create("request.sale.get", NULL), ^{
		[request startSynchronous];
		
        if (request.error)
        {
            [APP_DLG showAlertWithMessage:request.error.localizedDescription title:@"Request error"];
            
            return;
        }
        
        NSString *responseString = [request responseString];
        NSLog(@"%@", responseString);
        NSArray *resultArr = [responseString JSONValue];
        
		dispatch_async(dispatch_get_main_queue(), ^{
            
                        [self hideProgress];
            
            if(!resultArr || resultArr.count == 0)
            {
                [APP_DLG showAlertWithMessage:[NSString stringWithFormat:@"Could not find the place with id=%@", conversationId] title:@"Ups.."];
                return;
            }
            
            if (self.nearbyVenues.count)
            {
                [self.mapView removeAnnotations:self.nearbyVenues];
            }
            
            for (NSDictionary *dic in resultArr)
            {
                ZVenueModel *model = [ZVenueModel modelWithDictionary:dic];
                _visibleAnnotation = model;
                
                if(!self.nearbyVenues)
                    self.nearbyVenues = [NSMutableArray array];
                
                [self.nearbyVenues addObject:model];
                
                if(showOnMap)
                    [self.mapView setCenterCoordinate:model.coordinate animated:YES];
                break;
            }
            
            if (self.nearbyVenues.count)
            {
                [self.mapView addAnnotations:self.nearbyVenues];
            }
            

            
		});
	});
}

- (void)requestPersonsWithArguments:(NSDictionary *)arguments
{
	[self requestPersonsWithArguments:arguments showResults:(arguments != nil)];
}

- (void)requestPersonsWithArguments:(NSDictionary *)arguments showResults:(BOOL)show
{
	NSMutableDictionary *args = [NSMutableDictionary dictionaryWithCapacity:8];
	if (!arguments) {
//		NSString *searchText = [self.searchBar.text trimWhitespace];
//		if ([searchText length]) {
//			args[@"word"] = searchText;
//		}
		
		if (self.userModel.switchDistance) {
			int dist = self.userModel.pickerDistance;
			args[@"distance"] = [NSString stringWithFormat:@"%d", dist];
		}
		
		if (self.friendsOnlySwitch.on) {
			args[@"friends"] = @"1";
		}
	}
	else {
		[args setDictionary:arguments];
	}
	

	ZCommonRequest *request = [ZCommonRequest requestWithActionName:@"ping"];
	[request addPostValuesForKeys:args];
	LLog(@"(get all persons) %@", args);
	
	dispatch_async(dispatch_queue_create("request.ping", NULL), ^{
		[request startSynchronous];
		
		if (request.error) {
			dispatch_async(dispatch_get_main_queue(), ^{
                [APP_DLG showAlertWithMessage:request.error.localizedDescription title:@"Request error"];
			});
			return;
		}
		
		NSString *responseString = [request responseString];
        NSLog(@"%@", responseString);
		NSArray *arrRawPersons = [responseString componentsSeparatedByString:@"|-|"];
		NSMutableArray *allPersons = [NSMutableArray arrayWithCapacity:[arrRawPersons count]];
		for (NSString *component in arrRawPersons) {
			NSDictionary *dic = [NSDictionary dictionaryWithResponseString:component];
			if (dic.count) {
				ZPersonModel *model = [ZPersonModel modelWithDictionary:dic];
                
                BOOL visibleAreaContainPoint = MKMapRectContainsPoint(self.mapView.visibleMapRect, MKMapPointForCoordinate(model.coordinate)) ;
                
				if (model && (!self.isSearchResultsState || visibleAreaContainPoint)) {
					[allPersons addObject:model];
				}
			}
		}
		LLog(@"--->ALL PERSONS:\n%@", allPersons);
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self addPersonsArray:allPersons];
			
			//TODO: fix it
			if (show) {
				NSMutableArray *arr = [NSMutableArray arrayWithCapacity:32];
				for (ZPersonModel *model in allPersons) {
					NSMutableDictionary *dic = [NSMutableDictionary dictionary];
					[arr addObject:dic];
					if (!model.title) {
						LLog(@"???");
					}
					dic[@"formatted_address"] = model.nickname.length ? model.nickname : model.name;
					NSDictionary *location = @{@"lat" : @(model.coordinate.latitude), @"lng" : @(model.coordinate.longitude)};
					NSDictionary *geometry = @{@"location" : location};
					dic[@"geometry"] = geometry;
					dic[@"kModel"] = model;
				}
				
				ZGeoplaceSelViewController *ctr = [ZGeoplaceSelViewController controller];
				ctr.allGeoplaces = arr;
				ctr.delegate = self;
				if (arr.count == 0) {
					ctr.message = @"Nothing was found for your search criteria";
				}
				[self.navigationController pushViewController:ctr animated:YES];
			}
		});
	});
}

/*
- (void)requestMailWithArguments:(NSDictionary *)args showResults:(BOOL)show
{
    NSDictionary *timefilter = [self.userModel dateFilterArguments];
    [self requestMailWithArguments:args timeFilter:timefilter showResults:show];
}
*/

- (void)requestMailWithArguments:(NSDictionary *)args timeFilter:(NSDictionary*)timeFilter showResults:(BOOL)show
{
//	LLog(@"ARGUMENTS1:%@", args);
	ZCommonRequest *request = [ZCommonRequest  requestWithActionName:@"place"];
	NSMutableDictionary *arguments = [NSMutableDictionary dictionaryWithCapacity:8];
    
	if (timeFilter) {
		[arguments addEntriesFromDictionary:timeFilter];
	}
	if (args) {
		[arguments addEntriesFromDictionary:args];
	}
	LLog(@"ARGUMENTS2:%@", arguments);
	[request addPostValuesForKeys:arguments];
	
	dispatch_async(dispatch_queue_create("request.place", NULL), ^{
		[request startSynchronous];
        
		if (request.error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[APP_DLG showAlertWithMessage:request.error.localizedDescription title:@"Request error"];
			});
			return;
		}
        
		NSString *responseString = [request responseString];
		NSArray *resultArr = [responseString JSONValue];
		LLog(@"--->ALL MAIL JSON:\n%@", resultArr);
		NSMutableArray *arrEmails = [NSMutableArray arrayWithCapacity:[resultArr count]];
		for (NSDictionary *dict in resultArr) {
			ZMailDataModel *model = [ZMailDataModel mailDataModelWithDictionary:dict];
    
            BOOL visibleAreaContainPoint = MKMapRectContainsPoint(self.mapView.visibleMapRect, MKMapPointForCoordinate(model.coordinate)) ;
			if (model && (!self.isSearchResultsState || visibleAreaContainPoint)) {
                
				[arrEmails addObject:model];
			}
		}
		
		arrEmails = arrEmails.count ? arrEmails : nil;
        //		LLog(@"--->ALL MAIL:\n%@", arrEmails);
        
		dispatch_async(dispatch_get_main_queue(), ^{
			[self addMailArray:arrEmails];
			
			//TODO: fix it
			if (show) {
				NSMutableArray *arr = [NSMutableArray arrayWithCapacity:32];
				for (ZMailDataModel *model in arrEmails) {
					NSMutableDictionary *dic = [NSMutableDictionary dictionary];
					[arr addObject:dic];
					if (!model.title) {
						LLog(@"???");
					}
					dic[@"formatted_address"] = model.title ? model.title : @"?noname?";
					NSDictionary *location = @{@"lat" : @(model.coordinate.latitude), @"lng" : @(model.coordinate.longitude)};
					NSDictionary *geometry = @{@"location" : location};
					dic[@"geometry"] = geometry;
					dic[@"kModel"] = model;
				}
				
				ZGeoplaceSelViewController *ctr = [ZGeoplaceSelViewController controller];
				ctr.allGeoplaces = arr;
				ctr.delegate = self;
				if (arr.count == 0) {
					ctr.message = @"Nothing was found for your search criteria";
				}
				[self.navigationController pushViewController:ctr animated:YES];
				
			}
            
		});
	});
}

- (void)requestGeocodeWithSearchString:(NSString *)searchString
{
	
	if (!searchString) {
		LLog(@"NO zip code");
		return;
	}
	
	NSString *geoSURL = @"http://maps.googleapis.com/maps/api/geocode/json?sensor=true&address={0}";
	NSString *search = [searchString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
	NSString *surl = [geoSURL stringByReplacingOccurrencesOfString:@"{0}" withString:search];
	
	[self showSearchProgress];
	
	ASIHTTPRequest *req = [[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:surl]];
	dispatch_async(dispatch_queue_create("geocode.zip", NULL), ^{
		[req startSynchronous];
		LLog(@"resp:'%@'; err:'%@'", [req responseString], req.error);
		
		if (req.error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[APP_DLG showAlertWithMessage:req.error.localizedDescription title:@"Request error"];
			});
			return;
		}
		
		NSDictionary *resultDict = [[req responseString] JSONValue];
		LLog(@"%@", resultDict);
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
			[self hideSearchProgress];
			
			NSArray *arrResults = nil;
			NSString *status = resultDict[@"status"];
            
			if ([status isEqualToString:@"OK"])
            {
				arrResults = resultDict[@"results"];
			}
			
			ZGeoplaceSelViewController *ctr = [ZGeoplaceSelViewController controller];
			ctr.allGeoplaces = arrResults;
			ctr.delegate = self;
			ctr.textInfo = searchString;
			if (arrResults.count == 0)
            {
				ctr.message = [NSString stringWithFormat:@"Nothing was found for your search criteria\n'%@'", searchString];
			}
            
			[self.navigationController pushViewController:ctr animated:YES];
		});
	});
}

- (void)requestAllSales
{
	[self requestSalesWithTag:nil];
}

- (void)requestSalesWithTag:(NSString*)hashtag
{
    NSMutableDictionary *args = [NSMutableDictionary dictionary];
    
    [args setObject:@"get" forKey:@"action"];
    
    if(hashtag)
    {
        [args setObject:hashtag forKey:@"tag"];
    }
    
    //[super showProgress];
    
	ZCommonRequest *request = [ZCommonRequest requestWithActionName:@"sale" arguments:args];
    
	dispatch_async(dispatch_queue_create("request.sale.get", NULL), ^{
		[request startSynchronous];
		
        if (request.error)
        {
            [APP_DLG showAlertWithMessage:request.error.localizedDescription title:@"Request error"];
            
            return;
        }
        
        NSString *responseString = [request responseString];
        NSLog(@"%@", responseString);
        NSArray *resultArr = [responseString JSONValue];
        
        NSMutableArray *resArray = [NSMutableArray array];
        
        for (NSDictionary *dic in resultArr)
        {
            ZGarageSaleModel *model = [ZGarageSaleModel modelWithDictionary:dic];
            if([model.type isEqualToString:SALE_TYPE_GARAGE_SALE])
            {
                if([model.startTime timeIntervalSinceNow] < 0 && [model.endTime timeIntervalSinceNow] > 0)
                {
                    [resArray addObject:model];
                }
            }
            else
            {
                 [resArray addObject:model];
            }
        }
        
		dispatch_async(dispatch_get_main_queue(), ^{
			//[super hideProgress];
            [self addSalesArray:resArray];
		});
	});
}

- (void)requestUnreadNotifications
{
    NSMutableDictionary *args = [NSMutableDictionary dictionary];
    
    [args setObject:@"cnt_all" forKey:@"action"];
    
    //[super showProgress];
    
	ZCommonRequest *request = [ZCommonRequest requestWithActionName:@"notify" arguments:args];
    
	dispatch_async(dispatch_queue_create("request.sale.get", NULL), ^{
		[request startSynchronous];
        
		dispatch_async(dispatch_get_main_queue(), ^{
			//[super hideProgress];
            
            if (request.error)
            {
                [APP_DLG showAlertWithMessage:request.error.localizedDescription title:@"Request error"];
                
                return;
            }
            
            NSString *responseString = [request responseString];
            NSLog(@"%@", responseString);
            self.userModel.unreadNotificationsCount = [responseString intValue];
            
            [self updateNotificationBadge];
		});
	});
}

-(void)getVenuesForLocation:(CLLocationCoordinate2D)coordinate query:(NSString*)query_
{
//  NSString *firstChar = [query_ substringToIndex:1];
    NSString *locQuery;
    NSInteger limit = 0;
    
    if([query_ hasPrefix:@"#"]) {
//      locQuery = [query_ substringFromIndex:1];
        locQuery = [query_ stringByReplacingOccurrencesOfString:@"#" withString:@""];
        limit = 50;
    } else {
        return;
    }
    if (locQuery == nil)
        return;
    if (locQuery.length == 0)
        return;
    
    if (self.changeVenues) {
        self.changeVenues = NO; //only after Search button!!!
    } else {
        return;
    };
            
    NSLog(@"GET Venues Location for query:(%@)",query_);
    
    if(self.nearbyVenues.count > 0) {
        [self.mapView removeAnnotations:self.nearbyVenues];
    }
    self.nearbyVenues = nil;
    
    MKCoordinateRegion region = self.mapView.region;
    CLLocationCoordinate2D coordinate_ = region.center;    
        
    [Foursquare2 searchVenuesNearByLatitude:@(coordinate_.latitude)
								  longitude:@(coordinate_.longitude)
								 accuracyLL:nil
								   altitude:nil
								accuracyAlt:nil
									  query:locQuery 
									  limit:[NSNumber numberWithInt:limit]
									 intent:intentCheckin
//									 intent:intentMatch
//									 intent:intentBrowse
//                                   intent:intentGlobal
                                     radius:@(10000)
								   callback:^(BOOL success, id result){
									   if (success)
                                       {
										   NSDictionary *dic = result;
//                                         NSLog(@"(%@)",dic);
										   NSArray* venues = [dic valueForKeyPath:@"response.venues"];
                                           NSLog(@"----GOT %d Venues for %@---",venues.count,locQuery);
                                           FSConverter *converter = [[FSConverter alloc]init];                                           
//                                           if(self.nearbyVenues.count > 0)
//                                               [self.mapView removeAnnotations:self.nearbyVenues];
                                           self.nearbyVenues = [converter convertToVenueObjects:venues];
                                           
                                           [self.mapView addAnnotations:self.nearbyVenues];
                                           
                                           if (self.nearbyVenues.count < limit)
                                               [self getVenuesForLocation2:CLLocationCoordinate2DMake(coordinate_.latitude, coordinate_.longitude) query:query_];

									   } else {
                                           [self getVenuesForLocation2:CLLocationCoordinate2DMake(coordinate_.latitude, coordinate_.longitude) query:query_];
                                       }
								   }];
}

-(void)getVenuesForLocation2:(CLLocationCoordinate2D)coordinate query:(NSString*)query_
{
//  return;
    
    NSString *locQuery;
    NSInteger limit = 0;
    
    if([query_ hasPrefix:@"#"]) {
        locQuery = [query_ stringByReplacingOccurrencesOfString:@"#" withString:@""];
        limit = 50;
    } else {
        return;
    }
    
//   NSLog(@"GET2 Venues Location for query:(%@)",query_);
        
    [Foursquare2 searchVenuesNearByLatitude:@(coordinate.latitude)
								  longitude:@(coordinate.longitude)
								 accuracyLL:nil
								   altitude:nil
								accuracyAlt:nil
                                     query:locQuery
                                     limit:[NSNumber numberWithInt:limit]
                                     intent:intentBrowse
                                     radius:@(25000)
								   callback:^(BOOL success, id result){
									   if (success)
                                       {
										   NSDictionary *dic = result;
//                                         NSLog(@"(%@)",dic);
										   NSArray* venues = [dic valueForKeyPath:@"response.venues"];
                                           NSMutableArray* addVenues = [[[NSMutableArray alloc] init] autorelease];
                                           NSLog(@"----GOT2 %d Venues for %@---",venues.count,locQuery);
                                           FSConverter *converter = [[FSConverter alloc]init];
                                           self.nearbyVenues2 = [converter convertToVenueObjects:venues];
                                           NSArray *sortArr = [self.nearbyVenues2 sortedArrayUsingComparator: ^(id a, id b) {
                                                    NSNumber *first = ((ZVenueModel*)a).distance;
                                                    NSNumber *second = ((ZVenueModel*)b).distance;
                                                    float x1 = [first floatValue];
                                                    float x2 = [second floatValue];
                                                    if ( x1 < x2 ) {
                                                        return (NSComparisonResult)NSOrderedAscending;
                                                    } else if ( x1 > x2 ) {
                                                        return (NSComparisonResult)NSOrderedDescending;
                                                    } else {
                                                        return (NSComparisonResult)NSOrderedSame;
                                                    }                                            
                                           }];
                                        
                                           for (ZVenueModel *ven1 in sortArr) {
//                                               NSNumber *dist = ven1.distance;
//                                               NSLog(@"%@",dist);
                                               BOOL found = NO;
                                               for (ZVenueModel *ven2 in self.nearbyVenues) {  
                                                   if ([ven1.name isEqualToString:ven2.name] && [ven1.ID isEqualToString:ven2.ID])                                                     {
//                                                       NSLog(@">>found vanue:%@",ven1.name);
                                                       found = YES;
                                                       break;
                                                   }
                                               }
                                               if (!found && (addVenues.count + self.nearbyVenues.count < 100))
                                                   [addVenues  addObject:ven1];
                                           }
                                                                                      
                                           NSLog(@"----ADDED %d Venues---",addVenues.count);
                                           [self.nearbyVenues addObjectsFromArray:addVenues];
                                           [self.mapView addAnnotations:addVenues];
									   }
								   }];
    
}

#pragma mark - Service

- (void)showGeocodePlaceWithDictionary:(NSDictionary *)placeDict
{
	LLog(@"TODO: SHOW this place '%@'", placeDict);
	
	NSDictionary *dicLocation = [placeDict valueForKeyPath:@"geometry.location"];
	
	MKCoordinateRegion region;
	region.center = CLLocationCoordinate2DMake([dicLocation[@"lat"] doubleValue],
											   [dicLocation[@"lng"] doubleValue]);
	
	NSDictionary *dicNorth = [placeDict valueForKeyPath:@"geometry.viewport.northeast"];
	NSDictionary *dicSouth = [placeDict valueForKeyPath:@"geometry.viewport.southwest"];
	if (!dicSouth || !dicNorth) {
		dicNorth = [placeDict valueForKeyPath:@"geometry.bounds.northeast"];
		dicSouth = [placeDict valueForKeyPath:@"geometry.bounds.southwest"];
	}
	if (dicNorth && dicSouth) {
		CLLocationDegrees dLat = [dicNorth[@"lat"] doubleValue] - [dicSouth[@"lat"] doubleValue];
		if (dLat < 0) { dLat *= -1.0; }
		CLLocationDegrees dLon = [dicNorth[@"lng"] doubleValue] - [dicSouth[@"lng"] doubleValue];
		if (dLon < 0) {	dLon *= -1.0; }
		region.span = MKCoordinateSpanMake(dLat, dLon);
		LLog(@"span:%f,%f", dLat, dLon);
	}
	else {
		region.span = MKCoordinateSpanMake(0.02, 0.02);
		LLog(@"span const:0.02,0.02");
	}
	[_mapView setRegion:region animated:NO];
}

- (void)addPersonsArray:(NSMutableArray *)arrPersons
{
	if (self.allPersonModels.count) {
		[self.mapView removeAnnotations:self.allPersonModels];
	}
	self.allPersonModels = arrPersons;
	if (self.allPersonModels.count) {
		[self.mapView addAnnotations:self.allPersonModels];
	}
}

- (void)addMailArray:(NSMutableArray *)arrMails
{
    if (self.allMailModels.count)
    {
		[self.mapView removeAnnotations:self.allMailModels];
	}
	self.allMailModels = arrMails;
    
    if(_visibleAnnotation && [_visibleAnnotation isKindOfClass:[ZMailDataModel class]])
    {
        if(!self.allMailModels)
            self.allMailModels = [NSMutableArray array];
        
        [self.allMailModels addObject:_visibleAnnotation];
    }
    
	if (self.allMailModels.count)
    {
		[self.mapView addAnnotations:self.allMailModels];
	}
}

- (void)addSalesArray:(NSMutableArray *)arrSales
{
	
    if (self.allSalesModels.count)
    {
		[self.mapView removeAnnotations:self.allSalesModels];
	}
	self.allSalesModels = arrSales;
	if (self.allSalesModels.count)
    {
		[self.mapView addAnnotations:self.allSalesModels];
	}
}

#pragma mark - Map actions

- (void)showAnnotationHome:(ZTaggedButton *)button
{
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

- (void)showAnnotationPing:(ZTaggedButton *)button
{
	
	LLog(@"%@", button);
	
	ZPersonModel *personModel = button.userInfo;
	ZPersonProfileVC *ctr = [ZPersonProfileVC controller];
	ctr.personModel = personModel;
	[self.navigationController pushViewController:ctr animated:YES];
}

- (void)showAnnotationMailMessage:(ZTaggedButton *)button
{
	
	LLog(@"%@", button);
	
	ZMailDataModel *mailModel = button.userInfo;
    [self showMailMessage:mailModel];
}

- (void)showAnnotationOnGoogleMap:(ZUserInfoButton *)button
{
    CLLocationCoordinate2D loc = ((ZMailDataModel*)button.userInfo).coordinate;
    
    NSString *mapUrl = [NSString stringWithFormat: @"http://maps.google.com/maps?q=%f,%f", loc.latitude, loc.longitude];
    NSURL *url = [NSURL URLWithString:mapUrl];
    [[UIApplication sharedApplication] openURL:url];
}

-(void)showSaleOnGoogleMap:(ZUserInfoButton *)button
{
    CLLocationCoordinate2D loc = ((ZGarageSaleModel*)button.userInfo).coordinate;
    
    NSString *mapUrl = [NSString stringWithFormat: @"http://maps.google.com/maps?q=%f,%f", loc.latitude, loc.longitude];
    NSURL *url = [NSURL URLWithString:mapUrl];
    [[UIApplication sharedApplication] openURL:url];
}

-(IBAction)actOpenSale:(ZTaggedButton *)button
{
    ZProductSalePreviewViewController *ctrl = [ZProductSalePreviewViewController controller];
    ctrl.garageSaleModel = button.userInfo;
    ctrl.isReadonly = YES;
    [self.navigationController pushViewController:ctrl animated:YES];
}

-(IBAction)actOpenVenue:(ZTaggedButton *)button
{
    ZVenueConversationListVC *ctrl = [ZVenueConversationListVC controller];
    ctrl.venueModel = button.userInfo;
    [self.navigationController pushViewController:ctrl animated:YES];
}

-(void)showVenueOnGoogleMap:(ZUserInfoButton *)button
{
    CLLocationCoordinate2D loc = ((ZGarageSaleModel*)button.userInfo).coordinate;
    
    NSString *mapUrl = [NSString stringWithFormat: @"http://maps.google.com/maps?q=%f,%f", loc.latitude, loc.longitude];
    NSURL *url = [NSURL URLWithString:mapUrl];
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - MKMapView Annotations

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
	}
	
	if ([annotation respondsToSelector:@selector(mailDataModel)])
    {
		ZMailDataModel *model = [annotation performSelector:@selector(mailDataModel)];
		LLog(@"id:%@", model.ID);
	}
	
	if ([annotation isMemberOfClass:[ZMailDataModel class]]) {
		ZMailDataModel *mailModel = (ZMailDataModel *)annotation;
		return [mailModel annotationViewForMap:_mapView target:self action:@selector(showAnnotationMailMessage:) showOnMapAction:@selector(showAnnotationOnGoogleMap:)];
	}
	
	if (annotation == self.gpsAnnotation) {
        static NSString* ID = @"GPSAnnotationIdentifier";
        MKPinAnnotationView* pinView = (MKPinAnnotationView *)[_mapView dequeueReusableAnnotationViewWithIdentifier:ID];
        if (!pinView)
        {
            // if an existing pin view was not available, create one
            MKPinAnnotationView* customPinView = [[[MKPinAnnotationView alloc]
												   initWithAnnotation:annotation reuseIdentifier:ID] autorelease];
			
			
			customPinView.pinColor = MKPinAnnotationColorPurple;
            customPinView.animatesDrop = YES;
			customPinView.draggable = YES;
			
            return customPinView;
        }
        else
        {
            pinView.annotation = annotation;
        }
        return pinView;
    }
	
	if (annotation == self.homeAnnotation)
    {
        // try to dequeue an existing pin view first
        static NSString* ID = @"HomeAnnotationIdentifier";
        MKPinAnnotationView* pinView = (MKPinAnnotationView *)[_mapView dequeueReusableAnnotationViewWithIdentifier:ID];
        if (!pinView)
        {
            // if an existing pin view was not available, create one
            pinView = [[[MKPinAnnotationView alloc]
												   initWithAnnotation:annotation reuseIdentifier:ID] autorelease];
            
			
			pinView.pinColor = MKPinAnnotationColorGreen;
						
			pinView.animatesDrop = NO;
			pinView.canShowCallout = YES;
			pinView.draggable = NO;
			pinView.rightCalloutAccessoryView = [ZTaggedButton buttonWithTarget:self action:@selector(showAnnotationHome:)];
        }
        else
        {
            pinView.annotation = annotation;
        }
		
        return pinView;
    }
	
	/*
	if ([annotation isMemberOfClass:[ZPersonModel class]]) {
        // try to dequeue an existing pin view first
        static NSString* PingAnnotationIdentifier = @"PingAnnotationIdentifier";
        MKPinAnnotationView* pinView = (MKPinAnnotationView *)
			[_mapView dequeueReusableAnnotationViewWithIdentifier:PingAnnotationIdentifier];
        if (!pinView)
        {
            pinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation
												   reuseIdentifier:PingAnnotationIdentifier] autorelease];
			pinView.pinColor = MKPinAnnotationColorRed;
			pinView.animatesDrop = NO;
            pinView.canShowCallout = YES;
			pinView.draggable = NO;
			pinView.rightCalloutAccessoryView = [ZTaggedButton buttonWithTarget:self action:@selector(showAnnotationPing:)];
        }
        else
        {
            pinView.annotation = annotation;
        }
		
		ZTaggedButton *rightButton = (ZTaggedButton *)pinView.rightCalloutAccessoryView;
		rightButton.userInfo = annotation;
		
        return pinView;
    }
    */
    
    if ([annotation isMemberOfClass:[ZGarageSaleModel class]])
    {
		ZGarageSaleModel *model = (ZGarageSaleModel *)annotation;
        
		//return [model annotationViewForMap:_mapView target:self action:@selector(actOpenSale:)];
        
        return [model annotationViewForMap:_mapView target:self action:@selector(actOpenSale:) showOnMapAction:@selector(showSaleOnGoogleMap:)];
	}
    
    if ([annotation isMemberOfClass:[ZVenueModel class]])
    {
		ZVenueModel *model = (ZVenueModel *)annotation;
        
		//return [model annotationViewForMap:_mapView target:self action:@selector(actOpenSale:)];
        
        return [model annotationViewForMap:_mapView target:self action:@selector(actOpenVenue:) showOnMapAction:@selector(showVenueOnGoogleMap:)];
	}
    
    return nil;
}

#pragma mark - NewMessageViewControllerDelegate

- (void)newMessageViewController:(NewMessageViewController *)newMessageViewController
	didFinishWithNewMessageModel:(ZNewMessageModel *)model
{
	
	[self.navigationController popToViewController:self animated:YES];
	
	//	send this new message
	
	if (self.gpsAnnotation && [model isValid]) {
		
		model.sLatitude  = [NSString stringWithFormat:@"%f", self.gpsAnnotation.coordinate.latitude];
		model.sLongitude = [NSString stringWithFormat:@"%f", self.gpsAnnotation.coordinate.longitude];
		
		ZCommonRequest *request = [ZCommonRequest requestWithNewMessageModel:model];
		
		[super showProgress];
		dispatch_async(dispatch_queue_create("request.message.create", NULL), ^{
			[request startSynchronous];
			LLog(@"============== mail id '%@'", [request responseString]);
			LLog(@"response:'%@' (err:'%@')", [request responseString], request.error);

				dispatch_async(dispatch_get_main_queue(), ^{
                    
					[super hideProgress];
					
                    if (request.error) {
                        [APP_DLG showAlertWithMessage:request.error.localizedDescription title:@"Request error"];
                    }
                    
                    if (self.gpsAnnotation) {
						[_mapView removeAnnotation:self.gpsAnnotation];
						self.gpsAnnotation = nil;
					}
//                    _searchBar.text = nil; //zs
					[self updateMap];
				});
		});
	}
}

- (void)newMessageViewControllerDidCancel:(NewMessageViewController *)newMessageViewController
{
	[self.navigationController popToViewController:self animated:YES];
}

#pragma mark -

- (ZUserModel *)userModel
{
	return APP_DLG.currentUser;
}

- (void)invalidateMap
{
	self.isMapValid = NO;
	if (self.navigationController.visibleViewController == self) {
//        _searchBar.text = nil; //zs
		[self updateMap];
	}
}

#pragma mark - ZThisUserProfileVCDelegate

- (void)thisUserProfileVC:(ZThisUserProfileVC *)thisUserProfileVC
didSelectFavoriteLocationModel:(ZLocationModel *)locationModel
{
	if (!locationModel) {
		LLog(@"NO model??")
		return;
	}
	
	[self.navigationController popToViewController:self animated:YES];
	
	MKCoordinateRegion region;
	region.center = locationModel.coordinate;
	region.span = MKCoordinateSpanMake(0.02, 0.02);
	[self.mapView setRegion:region animated:YES];
}

#pragma mark - ZFavotiresListDelegate
-(void)favoriteListController:(ZFavoritesListViewController*)controller didSelectedFilterModel:(ZFavoriteFilterModel*)filterModel
{
    [self.navigationController popToViewController:self animated:YES];
    
    [self.searchBar setText:filterModel.searchText];
    self.isSearchResultsState = YES;
    
    NSDictionary *mapRectDic = filterModel.zipPlace;
    double x = [[mapRectDic objectForKey:@"x"] doubleValue];
    double y = [[mapRectDic objectForKey:@"y"] doubleValue];
    double width = [[mapRectDic objectForKey:@"width"] doubleValue];
    double height = [[mapRectDic objectForKey:@"height"] doubleValue];
    
    MKMapRect visibleMapRect = MKMapRectMake(x, y, width, height);
    [self.mapView setVisibleMapRect:visibleMapRect];
    
    if(![filterModel.type isEqualToString:FILTER_TYPE_LOCATION])
    {
        [self doSearchWithText:filterModel.searchText timeFilter:[filterModel.dateComponents dateFilterArguments]];
    }
    
    /*
    if([filterModel.type isEqualToString:FILTER_TYPE_LOCATION])
    {
        [self.navigationController popToViewController:self animated:NO];
        
        //self.searchBar.selectedScopeButtonIndex = 0;
        //[self showGeocodePlaceWithDictionary:filterModel.zipPlace];
    }
    else if([filterModel.type isEqualToString:FILTER_TYPE_USER])
    {
        //self.searchBar.selectedScopeButtonIndex = 1;
        NSMutableDictionary *args = [NSMutableDictionary dictionary];
        args[@"user"] = filterModel.searchText;
        args[@"word"] = filterModel.searchText;
        [self requestPersonsWithArguments:args showResults:NO];
    }
    else if([filterModel.type isEqualToString:FILTER_TYPE_HASHTAG])
    {
        [self.navigationController popToViewController:self animated:YES];
        
        //self.searchBar.selectedScopeButtonIndex = 1;
        
        NSMutableDictionary *args = [NSMutableDictionary dictionary];
        NSArray *arrHashtags = [filterModel.searchText extractHashtags];
        if (arrHashtags.count)
        {
            [self.userModel addHashtagsFromArray:arrHashtags];
            args[@"find"] = [arrHashtags componentsJoinedByString:@" "];
            
            [self requestMailWithArguments:args timeFilter:[filterModel.dateComponents dateFilterArguments] showResults:NO];
        }
    }
     */
}

@end

#pragma mark -

@implementation HomeViewController (ZipCode_Timer)

#pragma mark ZGeoplaceSelViewControllerDelegate

- (void)geoplaceSelViewController:(ZGeoplaceSelViewController *)geoplaceSelViewController didSelectZipPlace:(NSDictionary *)dictZipPlace;
{
    /*
	id model = dictZipPlace[@"kModel"];
    
	ZLocationModel *locModel = [[ZLocationModel new] autorelease];
	
	NSDictionary *dicLocation = [dictZipPlace valueForKeyPath:@"geometry.location"];
	locModel.coordinate = CLLocationCoordinate2DMake([dicLocation[@"lat"] doubleValue],
													 [dicLocation[@"lng"] doubleValue]);
	
	if (model)
    {
		LLog(@"MODEL: %@", model);
		if ([model isKindOfClass:[ZPersonModel class]]) {
			ZPersonModel *pm = (ZPersonModel *)model;
			locModel.title = pm.name;
			if (!locModel.title) {
				locModel.title = pm.nickname;
			}
		}
		else if ([model isKindOfClass:[ZMailDataModel class]]) {
			ZMailDataModel *mdm = (ZMailDataModel *)model;
			locModel.title = mdm.descript;
		}
	}
	else
    {
		LLog(@"TXT: %@", geoplaceSelViewController.textInfo);
		locModel.title = geoplaceSelViewController.textInfo;
	}
    */
    
	[self showGeocodePlaceWithDictionary:dictZipPlace];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)tickUpdateTimer:(NSTimer *)timer
{
	LLog(@"");
    
//	_searchBar.text = nil; //zs
	[self updateMap];
}

@end

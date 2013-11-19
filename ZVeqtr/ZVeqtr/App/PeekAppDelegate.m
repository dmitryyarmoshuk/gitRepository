//
//  PeekAppDelegate.m
//  Peek
//
//  Created by Pavel on 08.07.11.
//  Copyright 2011 Horns & Hoofs. All rights reserved.
//

#import "PeekAppDelegate.h"
#import "HomeViewController.h"
#import "ASIFormDataRequest.h"
#import "ZCommonRequest.h"
#import "PingSettingsViewController.h"
#import "ZUserModel.h"
#import "ZMailDataModel.h"
#import "InAppPurchaseManager.h"
#import "ZGarageSaleModel.h"


NSString *const kDidLoginSuccessfullyNotification = @"kDidLoginSuccessfullyNotification";
NSString *const kDidReceivePushNotification = @"kDidReceivePushNotification";


@interface PeekAppDelegate ()
@property (nonatomic, retain) NSDate *locationTimestamp;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSData *apnsDataToken;

@property (nonatomic, retain) NSDictionary *currentApns;

@end


@interface PeekAppDelegate (APNS)
- (void)registerForAPNS;
- (void)handleAPNS:(id)apns;
- (void)saveAPNSTokenOnServer;
@end

extern NSString *const ServerRootSURL;

@implementation PeekAppDelegate

@synthesize latitude;
@synthesize longitude;
@synthesize friendsArray;
@synthesize locationManagerStartDate;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoginSuccessfullyNotification:) name:kDidLoginSuccessfullyNotification object:nil];
	
	[UIApplication sharedApplication].applicationIconBadgeNumber = 0;

	self.currentUser = [ZUserModel restoreUser];
    
	latitude = 360;
	longitude = 360;
	
	// Maui (Hawaii).
	latitude = 20.8;
	longitude = -156.3333;
    
    //mosk 55,756492 37,622222
    
	
	firstUpdate = YES;
	
//	CLAuthorizationStatus stat = [CLLocationManager authorizationStatus];
	
	CLLocationManager *locMgr = [[[CLLocationManager alloc] init] autorelease];
	locMgr.delegate = self;
	locMgr.desiredAccuracy = kCLLocationAccuracyHundredMeters;
	locMgr.distanceFilter = 0.001;
	[locMgr startUpdatingLocation];
	self.locationManager = locMgr;
	
	self.locationManagerStartDate = [NSDate date];
	
    [[InAppPurchaseManager sharedManager] loadProductsWithIds:[NSMutableArray arrayWithObjects:
                [ZGarageSaleModel inAppPurchaseIdForSaleType:SALE_TYPE_GARAGE_SALE],
                [ZGarageSaleModel inAppPurchaseIdForSaleType:SALE_TYPE_PRODUCT],
                [ZGarageSaleModel inAppPurchaseIdForSaleType:SALE_TYPE_SERVICE],
                                                               nil]];
		
    [self.window makeKeyAndVisible];
    
	// 20.70, -156.40
	// 20.74, -156.45
	// 20.68, -156.44
	
	//latitude = 20.749;
	//longitude = -156.429;
	
	// test user 3
	//latitude = 20.68;
	//longitude = -156.44;
	
	[self registerForAPNS];
	
	id apns = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
	if (apns) {
		[self handleAPNS:apns];
	}

    return YES;
}

- (void)sendLocation {
	
	if (!self.sessionID.length) {
		return;
	}
	if (!APP_DLG.currentUser.username) {
		LLog(@"NO logged user");
		return;
	}

	NSDictionary *args = @{
		@"nickname":APP_DLG.currentUser.username,
		@"lon":[NSString stringWithFormat:@"%f", longitude],
		@"lat":[NSString stringWithFormat:@"%f", latitude]
	};
	ZCommonRequest *request = [ZCommonRequest requestWithActionName:@"settings" arguments:args];
	
	LLog(@"%@", args);
	
	dispatch_async(dispatch_queue_create("request.settings.location", NULL), ^{
		[request startSynchronous];
		
		LLog(@"sess:'%@'; resp:'%@'", self.sessionID, [request responseString]);
	});
}

- (void)loadFriends {
	
	self.friendsArray = [NSMutableArray array];
	
	NSString *str = [ServerRootSURL stringByAppendingFormat:@"friends.php?sess_id=%@&action=show", self.currentUser.sessionID];
	
	LLog(@"FROM:'%@'", str);
	
	NSError *error = nil;
	NSString *_content = [NSString stringWithContentsOfURL:[NSURL URLWithString:str] encoding:NSUTF8StringEncoding error:&error];
	LLog(@"RESPONSE:'%@'", _content);
	
	NSArray *array = [_content componentsSeparatedByString:@"-|-"];
	
	for (NSString *_id in array) {
		[self.friendsArray addObject:_id];
	}
	
	[self sendLocation];
	
	[self.homeViewController invalidateMap];
}

- (BOOL)isFriend:(NSString *)userID {
	for (NSString *_id in self.friendsArray) {
		if ([_id isEqualToString:userID]) return YES;
	}
	return NO;
}

- (BOOL)isValidLocation:(CLLocation *)newLocation
		withOldLocation:(CLLocation *)oldLocation
{
    // Filter out nil locations
    if (!newLocation)
    {
        return NO;
    }
    
    // Filter out points by invalid accuracy
    if (newLocation.horizontalAccuracy < 0)
    {
        return NO;
    }
    
    // Filter out points that are out of order
    NSTimeInterval secondsSinceLastPoint =
	[newLocation.timestamp timeIntervalSinceDate:oldLocation.timestamp];
    
    if (secondsSinceLastPoint < 0)
    {
        return NO;
    }
    
    // Filter out points created before the manager was initialized
    NSTimeInterval secondsSinceManagerStarted =
	[newLocation.timestamp timeIntervalSinceDate:self.locationManagerStartDate];
    
    if (secondsSinceManagerStarted < 0)
    {
        return NO;
    }
    
    // The newLocation is good to use
    return YES;
}

-(void)showAlertWithMessage:(NSString*)message title:(NSString*)title delegate:(id)delegate tag:(int)tag
{
    if(!self.isAlertVisible)
    {
        self.isAlertVisible = YES;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        alert.tag = tag;
        [alert show];
    }
}

-(void)showAlertWithMessage:(NSString*)message title:(NSString*)title
{
    [self showAlertWithMessage:message title:title delegate:self tag:666];
}

- (void)presentPingSettings {
	PingSettingsViewController *controller = [PingSettingsViewController controller];
	[(UINavigationController *)self.window.rootViewController pushViewController:controller animated:YES];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
	
	
	if ([self isValidLocation:newLocation withOldLocation:oldLocation]) {
		latitude = newLocation.coordinate.latitude;
		longitude = newLocation.coordinate.longitude;
		
		if (!self.locationTimestamp || -[self.locationTimestamp timeIntervalSinceNow] > 60) {
			//	Leonid: dont update too often
			[self sendLocation];
			self.locationTimestamp = [NSDate date];
		}
		
		if (firstUpdate) {
			if ([self.sessionID length] > 0) {
				[self.homeViewController invalidateMap];
			}
			
			firstUpdate = NO;
		}
	}
	
}


- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error {
	
	 //latitude = 20.5;
	// longitude = -156.3;
	
	LLog(@"%@", error);
	 
	if (firstUpdate) {
		if ([self.sessionID length] > 0) [self.homeViewController invalidateMap];
		firstUpdate = NO;
	}
}


#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {

    self.isAlertVisible = NO;
    
    if(alertView.tag == 666)
        return;
    
    if (buttonIndex == 1) {
        firstUpdate = YES;
        
        [self.locationManager stopUpdatingLocation];
        
        
        
        [self.locationManager startUpdatingLocation];
    
    }
}


#pragma mark - UIApplication

- (void)applicationWillResignActive:(UIApplication *)application {
	[self.currentUser saveUser];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
	NSDate *rqTimestamp = [ZCommonRequest lastRequestTimestamp];
	if (rqTimestamp && [rqTimestamp timeIntervalSinceNow] < -1*60*60)
	{
		//	no user, so the next step will be login
		self.currentUser.sessionID = nil;
		LLog(@"forgot the current user sessionID");
		[self.navigationController popToRootViewControllerAnimated:NO];
	}
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
	[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}


- (void)applicationWillTerminate:(UIApplication *)application {
	[self.currentUser saveUser];
}


#pragma mark - Facebook back management
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
//    return [FBSession.activeSession handleOpenURL:url];
    
//zsf    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
// add app-specific handling code here
//zsf    return wasHandled;
    
    
    BOOL wasHandled = [self.facebook handleOpenURL:url];
    return wasHandled;
//  return YES;
}

#pragma mark - Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
}


- (void)dealloc {
    self.window = nil;
    [super dealloc];
}

#pragma mark - Services

- (void)goHome {
	[(UINavigationController *)self.window.rootViewController popToRootViewControllerAnimated:YES];
}

- (void)invalidateMap {
	[[self homeViewController] invalidateMap];
}

- (BOOL)didUserLogin {
	return (self.sessionID.length > 0);
}

- (NSString *)sessionID {
	return self.currentUser.sessionID;
}

- (void)updateUser:(ZUserModel *)aUserModel {
	if (!self.currentUser) {
		self.currentUser = aUserModel;
	}
	else {
		if (![self.currentUser.username isEqualToString:aUserModel.username]) {
			self.currentUser = aUserModel;
            self.currentUser.facebookUsername = aUserModel.facebookUsername;
		}
		else {
			self.currentUser.sessionID = aUserModel.sessionID;
			self.currentUser.ID = aUserModel.ID;
            self.currentUser.unreadNotificationsCount = aUserModel.unreadNotificationsCount;
		}
	}
    
    //
	[self.currentUser restoreDateComponents];//<-- not too good
    [self.currentUser restoreCurrentFilters];//<-- not too good
    
	if (!self.currentUser.dateComponents) {
		//	set default values
		[self.currentUser resetTimeFilters];
	}
	[self.currentUser saveUser];
}


- (NSString *)homeSubtitle
{
    NSString *text = @"";
	
	for (int i = 0; i < 10; i++) {
		
		NSString *key = [NSString stringWithFormat:@"ln%d", i + 1];
		
		NSString *_text = [[NSUserDefaults standardUserDefaults] objectForKey:key];
		if ([_text length] > 0) {
			
			key = [NSString stringWithFormat:@"ln%d_v", i + 1];
			
			if ([[NSUserDefaults standardUserDefaults] boolForKey:key]) {
				
				if ([text length] > 0) {
					text = [NSString stringWithFormat:@"%@, ", text];
				}
				
				text = [NSString stringWithFormat:@"%@%@", text, _text];
				
			}
		}
	}
	
	return text;
}


- (NSString *)apnsToken {
	return [self.apnsDataToken hexString];
}


#pragma mark -

- (void)didLoginSuccessfullyNotification:(NSNotification *)notification {
	[self saveAPNSTokenOnServer];
}

- (void)updateAPNSTokenOnServer {
	[self saveAPNSTokenOnServer];
}


@end


@implementation PeekAppDelegate (APNS)

- (void)registerForAPNS
{
	NSUInteger types =
	UIRemoteNotificationTypeBadge |
	UIRemoteNotificationTypeSound |
	UIRemoteNotificationTypeAlert;
	
	NSUInteger registeredTypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
	
	registeredTypes = 0;
	LLog(@"DEBUG APNS");
	
	if (registeredTypes != types) {
		[[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
	}
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
	self.apnsDataToken = deviceToken;
	[self saveAPNSTokenOnServer];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
	LLog(@"%@", error);
	self.apnsDataToken = nil;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
	LLog(@"%@", userInfo);
	
	[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
	if (self.currentUser)
    {
		[self handleAPNS:userInfo];
	}
	else
    {
		LLog(@"APNS arrived but there is no user;");
        
		[self handleAPNS:userInfo];
	}
}

- (void)handleAPNS:(NSDictionary *)apns
{
	LLog(@"%@", apns);
    
    self.currentApns = apns;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidReceivePushNotification object:apns];
	
	NSString *message = [apns valueForKeyPath:@"aps.alert"];
    NSString *notify_cnt = [apns valueForKeyPath:@"server.notify_cnt"];
    
    self.currentUser.unreadNotificationsCount = [notify_cnt intValue];
	[self.homeViewController updateNotificationBadge];
    
    NSString *mailId = [self.currentApns valueForKeyPath:@"server.place_id"];
    if(mailId && ![mailId isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You Received A Notification"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Open", nil];
        [alert show];
        [alert release];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You Received A Notification"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (void)saveAPNSTokenOnServer
{
	
	if (!self.currentUser || !self.currentUser.sessionID) {
		//	cannot perform request without user
		LLog(@"Cannot send APNS token without a user or sessionID");
		return;
	}

	NSData *dataToken = self.apnsDataToken;
	if (!dataToken) {
		LLog(@"NO device token");
		return;
	}

	NSString *strToken = [dataToken hexString];
	BOOL wasTokenSent = [strToken isEqualToString:self.currentUser.apnsToken];
	if (wasTokenSent) {
		LLog(@"Server has this apns token: %@", self.currentUser.apnsToken);
		return;
	}
	
	LLog(@"'%@'; '%@'", dataToken, strToken);
	self.currentUser.apnsToken = nil;
	
	ZCommonRequest *request = [ZCommonRequest requestWithActionName:@"settings" arguments:@{@"token" : strToken}];
	dispatch_async(dispatch_queue_create("settings.token", NULL), ^{
		[request startSynchronous];
		dispatch_async(dispatch_get_main_queue(), ^{
			if (!request.error) {
				self.currentUser.apnsToken = strToken;
			}
			else {
				LLog(@"ERROR %@", request.error);
			}
		});
		
		LLog(@"token sent, resp:'%@', err:'%@'", [request responseString], [request error]);
	});
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	LLog(@"%d", buttonIndex);
	if (buttonIndex == alertView.cancelButtonIndex)
    {
		return;
	}
	else
    {
        
        
        
        NSNumber *placeId = [self.currentApns valueForKeyPath:@"server.place_id"];
        NSNumber *saleItemId = [self.currentApns valueForKeyPath:@"server.sale_item_id"];
        NSNumber *conversId = [self.currentApns valueForKeyPath:@"server.convers_id"];
        
        NSNumber *type = [self.currentApns valueForKeyPath:@"server.type"];
                
        if(type)
        {
            //1 places
            //2 comments
            //3 venues_convers
            //4 venues_comments
            if([type intValue] == 1 || [type intValue] == 2)
            {
                [self.homeViewController showMailMessageWithId:[NSString stringWithFormat:@"%d", [placeId intValue]]];
            }
            else if([type intValue] == 3 || [type intValue] == 4)
            {
                [self.homeViewController showVenueConversationId:[NSString stringWithFormat:@"%d", [placeId intValue]]];
            }
        }
        else if(placeId)
        {
            [self.homeViewController showMailMessageWithId:[NSString stringWithFormat:@"%d", [placeId intValue]]];
        }
        else if(conversId)
        {
            [self.homeViewController showVenueConversationId:[NSString stringWithFormat:@"%d", [conversId intValue]]];
        }
    }
}

@end

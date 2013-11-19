//
//  PeekAppDelegate.h
//  Peek
//
//  Created by Pavel on 08.07.11.
//  Copyright 2011 Horns & Hoofs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZUserModel.h"

#import "Facebook.h"

NSString *const kDidLoginSuccessfullyNotification;
NSString *const kDidReceivePushNotification;

@class HomeViewController;

@interface PeekAppDelegate : NSObject
<UIApplicationDelegate, CLLocationManagerDelegate>
{
	NSDate *locationManagerStartDate;
	CLLocationDegrees latitude;
	CLLocationDegrees longitude;
	NSMutableArray *friendsArray;
	BOOL firstUpdate;
}

@property (nonatomic, assign) BOOL isAlertVisible;

- (void)loadFriends;
- (BOOL)isFriend:(NSString *)userID;
//Leonid:
- (void)presentPingSettings;

- (void)goHome;

- (void)invalidateMap;
- (NSString *)homeSubtitle;

@property (nonatomic, readonly) NSString *apnsToken;
@property CLLocationDegrees latitude;
@property CLLocationDegrees longitude;

@property (nonatomic, retain) IBOutlet UINavigationController	*navigationController;
@property (nonatomic, retain) IBOutlet UIWindow		*window;
@property (nonatomic, retain) IBOutlet HomeViewController *homeViewController;
@property (nonatomic, retain) NSMutableArray *friendsArray;
@property (nonatomic, retain) NSDate *locationManagerStartDate;

@property (nonatomic, assign) NSDate *filterFromDate;
@property (nonatomic, assign) NSDate *filterToDate;

@property(nonatomic, assign)   Facebook *facebook;

//	logged in user
@property (nonatomic, retain) ZUserModel *currentUser;
@property (nonatomic, readonly) NSString *sessionID;
- (BOOL)didUserLogin;

- (void)updateUser:(ZUserModel *)aUserModel;

- (void)updateAPNSTokenOnServer;

-(void)showAlertWithMessage:(NSString*)message title:(NSString*)title;

@end


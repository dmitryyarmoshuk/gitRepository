//
//  ZThisUserProfileVC.h
//  ZVeqtr
//
//  Created by Lee Loo on 10/22/12.
//  Copyright (c) 2012 PE-Leonid.Lo. All rights reserved.
//

#import "ZSuperViewController.h"
#import "ZUserSettingBoolCell.h"
#import "ZSelectLanguageViewController.h"
//#import <FacebookSDK/FacebookSDK.h>
#import "FBSession.h"
#import "EGOImageView.h"

@class ZUserModel;
@class ZLocationModel;
@protocol ZThisUserProfileVCDelegate;

@interface ZThisUserProfileVC : ZSuperViewController <ZUserSettingBoolCellDelegate, ZSelectLanguageViewControllerDelegate,FBSeccionDelegate> //zsf, FBLoginViewDelegate>
{}

@property (nonatomic, retain) ZUserModel	*userModel;
@property (nonatomic, assign) id<ZThisUserProfileVCDelegate> delegate;


- (void)fbDidLogin:(NSString*)token expDate:(NSDate*)date;
- (void)fbDidLogin:(NSString*)token expDate:(NSDate*)date withInfo:(NSDictionary*)result;

- (void)imageLoaderDidLoad:(NSNotification*)notification;
- (void)imageViewFailedToLoadImage:(EGOImageView*)imageView error:(NSError*)error;

- (void)imageViewLoadedImage:(EGOImageView*)eIimage;
- (void)imageViewFailedToLoadImage:(EGOImageView*)eIimage;

@end


@protocol ZThisUserProfileVCDelegate <NSObject>
@required
- (void)thisUserProfileVC:(ZThisUserProfileVC *)thisUserProfileVC
didSelectFavoriteLocationModel:(ZLocationModel *)locationModel;
@end

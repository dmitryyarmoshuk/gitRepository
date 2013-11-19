//
//  ZSuperViewController.h
//  ZVeqtr
//
//  Created by Leonid Lo on 10/15/12.
//  Copyright (c) 2012 PE-Leonid.Lo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSURL+ZVeqtr.h"
#import "NSString+ZVeqtr.h"

@interface ZSuperViewController : UIViewController
{}

+ (id)controller;
- (IBAction)actGoBack;
- (IBAction)actGoHome;
- (UIBarButtonItem *)backBarButtonItem;
- (void)presentBackBarButtonItem;
- (UIBarButtonItem *)saveBarButtonItem;
- (void)presentSaveBarButtonItem;
- (UIBarButtonItem *)settingsBarButtonItem;
- (UIBarButtonItem *)homeBarButtonItem;
- (void)presentEmptyBackBarButtonItem;

- (void)releaseOutlets;

@property (nonatomic, retain) IBOutlet UIView *viewContainer;
@property (nonatomic, retain) UIViewController  *presenterViewController;

- (void)showProgress;
- (void)hideProgress;

@end


@interface ZSuperViewController (Keyboard)
//	call these 2 to subscribe/unsubscribe for/from keyboard notifications
- (void)subscribeForKeyboardNotifications;
- (void)unsubscribeFromKeyboardNotifications;
//	keyboard notifications handlers to override
- (void)keyboardWillShowNotification:(NSNotification *)notification;
- (void)keyboardDidShowNotification:(NSNotification *)notification;
- (void)keyboardWillHideNotification:(NSNotification *)notification;
- (void)keyboardDidHideNotification:(NSNotification *)notification;
@end


@interface ZSuperViewController (TakePicture)
<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>
//	first it shows an action sheet (tag=999) to select where to take a pic from
- (void)takePicture;
//	to override to handle the result picture
- (void)savePicture:(UIImage *)picture;
@end

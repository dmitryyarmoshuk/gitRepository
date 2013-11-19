//
//  ZCpmmentsListVC.h
//  ZVeqtr
//
//  Created by Lee Loo on 10/23/12.
//  Copyright (c) 2012 PE-Leonid.Lo. All rights reserved.
//

#import "ZSuperViewController.h"
#import "EGOImageView.h"
#import "ZMessageInDetailVC.h"

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


@class ZMailDataModel;
@class ZUserModel;

@interface ZCommentsListVC : ZSuperViewController
<UIActionSheetDelegate, EGOImageViewDelegate, ZMessageInDetailVCDelegate, MFMailComposeViewControllerDelegate>
{
    BOOL _shouldScrollToBottom;
}

@property (nonatomic, retain) ZMailDataModel	*mailModel;
@property (nonatomic, retain) ZUserModel		*userModel;

//- (IBAction)actShowEmoji:(id)sender;
- (void)reloadData;

@end

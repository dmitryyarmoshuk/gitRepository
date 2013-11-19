//
//  ZVenueConversationVC.h
//  ZVeqtr
//
//  Created by Maxim on 6/10/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
#import "ZMessageInDetailVC.h"

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


@class ZVenueModel;
@class ZConversationModel;

@interface ZVenueConversationVC : ZSuperViewController
<UIActionSheetDelegate, EGOImageViewDelegate, ZMessageInDetailVCDelegate, MFMailComposeViewControllerDelegate>
{
        BOOL _shouldScrollToBottom;
}

@property (nonatomic, retain) ZVenueModel *venueModel;
@property (nonatomic, retain) ZConversationModel *conversationModel;
@property (nonatomic, assign) NSInteger index;

//- (IBAction)actShowEmoji:(id)sender;
- (void)reloadData;

@end

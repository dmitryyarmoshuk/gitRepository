//
//  ZPersonProfileVC.h
//  ZVeqtr
//
//  Created by Lee Loo on 10/22/12.
//  Copyright (c) 2012 PE-Leonid.Lo. All rights reserved.
//

#import "ZSuperViewController.h"
#import "OHAttributedLabel.h"


@class ZPersonModel;
@class ZUserModel;
@class ZCommentOnMessageModel;
@class ZMailDataModel;

@interface ZPersonProfileVC : ZSuperViewController <UIActionSheetDelegate, OHAttributedLabelDelegate>
{}

@property (nonatomic, retain) ZMailDataModel            *mailDataModel;
@property (nonatomic, retain) ZCommentOnMessageModel	*commentModel;
@property (nonatomic, retain) ZPersonModel				*personModel;
@property (nonatomic, retain) ZUserModel				*userModel;
@property (nonatomic, retain) NSString					*personID;
@property (nonatomic, retain) NSString					*username;

@end

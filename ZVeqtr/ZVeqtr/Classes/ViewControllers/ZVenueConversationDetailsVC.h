//
//  ZVenueConversationDetailsVC.h
//  ZVeqtr
//
//  Created by Maxim on 6/21/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZSuperViewController.h"

@class ZConversationModel;
@class ZVenueModel;

@interface ZVenueConversationDetailsVC : ZSuperViewController
{
    __weak IBOutlet UITextField *_textName;
}

@property (nonatomic, strong) ZConversationModel *conversationModel;
@property (nonatomic, strong) ZVenueModel *venueModel;

@end

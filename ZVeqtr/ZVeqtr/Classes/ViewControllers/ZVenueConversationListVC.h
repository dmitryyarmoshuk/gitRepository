//
//  ZVenueConversationListVC.h
//  ZVeqtr
//
//  Created by Maxim on 6/21/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSuperViewController.h"

@class ZVenueModel;


@interface ZVenueConversationListVC : ZSuperViewController
{
    __weak IBOutlet UITableView *_table;
}

@property (nonatomic, strong) ZVenueModel *venueModel;

@end

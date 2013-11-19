//
//  ZMessageCenterViewController.h
//  ZVeqtr
//
//  Created by Maxim on 2/13/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZSuperViewController.h"
#import "ZNotificationCell.h"

@interface ZMessageCenterViewController : ZSuperViewController<UITableViewDataSource, UITableViewDelegate, ZNotificationCellDelegate>

@property (nonatomic, strong) NSString *notificationType;

@end

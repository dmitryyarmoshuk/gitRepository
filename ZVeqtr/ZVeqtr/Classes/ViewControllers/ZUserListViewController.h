//
//  ZUserListViewController.h
//  ZVeqtr
//
//  Created by Maxim on 2/4/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSuperViewController.h"
#import "ZPersonCell.h"

@interface ZUserListViewController : ZSuperViewController<UITableViewDataSource, UITableViewDelegate, ZPersonCellDelegate>


-(id)initAsFriends:(NSString*)userId;
-(id)initAsFolowers:(NSString*)userId;
-(id)initAsFollowing:(NSString*)userId;

-(id)initAsFriendRequests:(NSString*)userId;

@end

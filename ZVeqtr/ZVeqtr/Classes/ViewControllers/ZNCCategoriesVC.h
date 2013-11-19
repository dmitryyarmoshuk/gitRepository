//
//  ZNCCategoriesVC.h
//  ZVeqtr
//
//  Created by Maxim on 19.10.13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSuperViewController.h"
#import "CustomBadge.h"

@interface ZNCCategoriesVC : ZSuperViewController <UITableViewDelegate, UITableViewDataSource>
{
    int _commentsCount;
    int _messagesCount;
    int _legitsCount;
    int _salesCount;
    int _friendRequestsCount;
    int _followersCount;
    
    __weak IBOutlet UIView *_commentsSectionView;
    __weak IBOutlet UIView *_messagesSectionView;
    __weak IBOutlet UIView *_legitSectionView;
    __weak IBOutlet UIView *_salesSectionView;
    __weak IBOutlet UIView *_friendSectionView;
    __weak IBOutlet UIView *_followersSectionView;
    
    __weak IBOutlet CustomBadge *_commentsBadge;
    __weak IBOutlet CustomBadge *_messagesBadge;
    __weak IBOutlet CustomBadge *_legitsBadge;
    __weak IBOutlet CustomBadge *_salesBadge;
    __weak IBOutlet CustomBadge *_friendsBadge;
    __weak IBOutlet CustomBadge *_followersBadge;
}

@end

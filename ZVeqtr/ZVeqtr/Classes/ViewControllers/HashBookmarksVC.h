//
//  HashBookmarksVC.h
//  ZVeqtr
//
//  Created by Lee Loo on 10/16/12.
//  Copyright (c) 2012 PE-Leonid.Lo. All rights reserved.
//

#import "ZSuperViewController.h"

@protocol HashBookmarksVCDelegate;

@interface HashBookmarksVC : ZSuperViewController
<UITableViewDataSource, UITableViewDelegate>
{}
@property (nonatomic, assign) id<HashBookmarksVCDelegate> delegate;
@property (nonatomic, retain) NSArray	*allDisabledHashtags;
+ (BOOL)hasBookmarks;

@end


@protocol HashBookmarksVCDelegate <NSObject>
@required
- (void)hashBookmarksVC:(HashBookmarksVC *)hashBookmarksVC didSelectTagString:(NSString *)tagString;
@end

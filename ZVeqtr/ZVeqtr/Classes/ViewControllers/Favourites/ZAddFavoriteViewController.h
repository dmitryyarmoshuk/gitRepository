//
//  ZAddFavoriteViewController.h
//  ZVeqtr
//
//  Created by Maxim on 1/24/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZSuperViewController.h"

@interface ZAddFavoriteViewController : ZSuperViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) NSString *filterName;
@property (nonatomic, retain) NSString *filterType;
@property (nonatomic, retain) NSDictionary *selectedZipPlace;

@property (nonatomic, retain) ZFavoriteFilterModel *model;

@end
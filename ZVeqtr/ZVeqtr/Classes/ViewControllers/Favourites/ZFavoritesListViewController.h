//
//  ZFavoritesListViewController.h
//  ZVeqtr
//
//  Created by Maxim on 1/24/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZSuperViewController.h"
#import "ZFavoriteCell.h"

@class ZFavoriteFilterModel;
@protocol ZFavoritesListDelegate;

@interface ZFavoritesListViewController :ZSuperViewController <UITableViewDataSource, UITableViewDelegate, ZFavoriteCellDelegate>

@property (nonatomic, retain) id<ZFavoritesListDelegate> delegate;

@end

@protocol ZFavoritesListDelegate <NSObject>
@optional
-(void)favoriteListController:(ZFavoritesListViewController*)controller didSelectedFilterModel:(ZFavoriteFilterModel*)filterModel;

@end
//
//  ZFavoriteCell.h
//  ZVeqtr
//
//  Created by Maxim on 1/24/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"

@protocol ZFavoriteCellDelegate;

@interface ZFavoriteCell : UITableViewCell

@property (nonatomic, retain) id<ZFavoriteCellDelegate> delegate;
@property (nonatomic, retain) EGOImageView *filterImage;

@end

@protocol ZFavoriteCellDelegate <NSObject>
@optional
-(void)pictureButtonClickedInCell:(ZFavoriteCell*)cell;

@end
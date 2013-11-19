//
//  ZPersonCell.h
//  ZVeqtr
//
//  Created by Maxim on 2/4/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EGOImageView;

@protocol ZPersonCellDelegate;

@interface ZPersonCell : UITableViewCell

+ (ZPersonCell *)cell;

@property (nonatomic, assign) IBOutlet UILabel	*labTitle;
@property (nonatomic, assign) IBOutlet UIView	*picBack;
@property (nonatomic, assign) IBOutlet EGOImageView *picture;
@property (nonatomic, assign) id<ZPersonCellDelegate> delegate;

-(void)setButtonsVisible:(BOOL)value;

@end

@protocol ZPersonCellDelegate <NSObject>

-(void)cellApprovedFriend:(ZPersonCell*)cell;
-(void)cellDeclinedFriend:(ZPersonCell*)cell;

@end
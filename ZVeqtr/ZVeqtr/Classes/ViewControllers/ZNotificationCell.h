//
//  ZNotificationCell.h
//  ZVeqtr
//
//  Created by Maxim on 2/13/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OHAttributedLabel.h"

@class EGOImageView;
@class ZNotificationModel;
@protocol ZNotificationCellDelegate;

@interface ZNotificationCell : UITableViewCell<OHAttributedLabelDelegate>
{
    __weak IBOutlet UIButton *_buttonToMap;
}

+ (ZNotificationCell *)cell;

@property (nonatomic, assign) IBOutlet OHAttributedLabel	*labUsername;
@property (nonatomic, assign) IBOutlet OHAttributedLabel	*labAction;
@property (nonatomic, assign) IBOutlet OHAttributedLabel	*labMessage;
@property (nonatomic, assign) IBOutlet UILabel	*labActionDate;

@property (nonatomic, assign) IBOutlet UIView	*picBack;
@property (nonatomic, assign) IBOutlet EGOImageView *picture;

@property (nonatomic, assign) id<ZNotificationCellDelegate> delegate;
@property (nonatomic, retain) ZNotificationModel	*notificationModel;
- (CGFloat)heightWithNotificationModel:(ZNotificationModel *)model;
@end


@protocol ZNotificationCellDelegate <NSObject>
@required
-(void)notificationCellUsernameClicked:(ZNotificationCell*)cell;
-(void)notificationCellPostClicked:(ZNotificationCell*)cell;
-(void)notificationCellToMapButtonClicked:(ZNotificationCell*)cell;

@end

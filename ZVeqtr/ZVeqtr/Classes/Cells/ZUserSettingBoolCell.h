//
//  ZUserSettingBoolCell.h
//  ZVeqtr
//
//  Created by Maxim on 2/4/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZUserSettingBoolCellDelegate;

@interface ZUserSettingBoolCell : UITableViewCell

@property (nonatomic, assign) IBOutlet UILabel *labelName;
@property (nonatomic, assign) IBOutlet UISwitch *switchControl;

@property (nonatomic, assign) id<ZUserSettingBoolCellDelegate> delegate;

+ (ZUserSettingBoolCell *)cell;

@end

@protocol ZUserSettingBoolCellDelegate <NSObject>
@optional
-(void)cellSwitchValueChanged:(ZUserSettingBoolCell*)cell;

@end
//
//  CustomTextTableViewCell_iPhone.h
//  Peek
//
//  Created by Pavel on 14.06.11.
//  Copyright 2011 Horns & Hoofs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OHAttributedLabel.h"


@class ZSmartTextView;
@class ZUserModel;

@interface TextTableViewCell : UITableViewCell<OHAttributedLabelDelegate>
{
	int index;
}

@property (nonatomic, assign) IBOutlet UISwitch *switchTextField;
@property (nonatomic, assign) IBOutlet OHAttributedLabel *labelText;
@property (nonatomic, strong) ZUserModel *userModel;

+ (TextTableViewCell *)cell;

- (void)updateDataWithText:(NSString*)text;
- (void)updateData:(int)_index;

- (CGFloat)heightForObject:(ZUserModel*)userModel atIndex:(int)indx isSwitchVisible:(BOOL)isSwitchVisible;
-(CGFloat)heightForText:(NSString*)customText isSwitchVisible:(BOOL)isSwitchVisible;

@end

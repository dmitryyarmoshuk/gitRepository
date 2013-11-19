//
//  ZUserSettingBoolCell.m
//  ZVeqtr
//
//  Created by Maxim on 2/4/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZUserSettingBoolCell.h"

@implementation ZUserSettingBoolCell

- (NSString *) reuseIdentifier {
    return @"ZUserSettingBoolCell";
}

+ (ZUserSettingBoolCell *)cell {
	return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] lastObject];
}

-(IBAction)switchValue_Changed:(id)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(cellSwitchValueChanged:)])
    {
        [self.delegate cellSwitchValueChanged:self];
    }
}

@end

//
//  ZMailListCell.m
//  ZVeqtr
//
//  Created by Maxim on 2/4/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZMailListCell.h"

#import <QuartzCore/QuartzCore.h>


@implementation ZMailListCell

- (void)awakeFromNib {
	UIFont *font = [UIFont fontWithName:@"RBNo3.1-Black" size:16];
	if (font) {
		_labTitle.font = font;
		_labNickname.font = font;
        
		_picBack.layer.masksToBounds = YES;
		_picBack.layer.cornerRadius = 4;
		_picBack.layer.borderColor = [UIColor grayColor].CGColor;
		_picBack.layer.borderWidth = 1;
	}
}

+ (ZMailListCell *)cell {
	return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] lastObject];
}

@end

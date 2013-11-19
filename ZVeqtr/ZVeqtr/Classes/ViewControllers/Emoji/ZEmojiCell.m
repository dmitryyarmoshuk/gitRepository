//
//  ZEmojiCell.m
//  ZVeqtr
//
//  Created by Leonid Lo on 1/9/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZEmojiCell.h"

@implementation ZEmojiCell

+ (ZEmojiCell *)cell {
	return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil][0];
}

- (IBAction)actSelectEmoji:(UIButton *)sender {
	[self.delegate emojiCell:self didSelectSymbol:[sender titleForState:UIControlStateNormal]];
	sender.alpha = 0.5;
	sender.transform = CGAffineTransformMakeScale(1.5, 1.5);
	[UIView animateWithDuration:0.3 animations:^{
		sender.alpha = 1;
		sender.transform = CGAffineTransformIdentity;
	}];
}

@end

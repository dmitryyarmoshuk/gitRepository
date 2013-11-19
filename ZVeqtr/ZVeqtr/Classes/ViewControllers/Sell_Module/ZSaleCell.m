//
//  ZSaleCell.m
//  ZVeqtr
//
//  Created by Maxim on 4/17/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZSaleCell.h"

@implementation ZSaleCell

- (void)awakeFromNib
{
    /*
     UIFont *font = [UIFont fontWithName:@"RBNo3.1-Black" size:16];
     if (font) {
     _labTitle.font = font;
     _labNickname.font = font;
     
     _picBack.layer.masksToBounds = YES;
     _picBack.layer.cornerRadius = 4;
     _picBack.layer.borderColor = [UIColor grayColor].CGColor;
     _picBack.layer.borderWidth = 1;
     }
     */
    
    UIFont *font = [UIFont fontWithName:@"RBNo3.1-Black" size:16];
    if (font)
    {
        self.labelName.font = font;
    }
    
    self.labelStatus.text = @"";
    self.labelName.text = @"";
    self.labelDescription.text = @"";
}

+ (ZSaleCell *)cell
{
	return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] lastObject];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    if(!self.labelDescription.text || [self.labelDescription.text isEqualToString:@""])
    {
        self.labelName.frame = CGRectMake(15, 5, 216, 44);
    }
    else
    {
        self.labelName.frame = CGRectMake(15, 5, 216, 22);
        self.labelDescription.frame = CGRectMake(15, 27, 216, 22);
    }
}

@end

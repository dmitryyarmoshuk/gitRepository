//
//  ZPersonCell.m
//  ZVeqtr
//
//  Created by Maxim on 2/4/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZPersonCell.h"
#import <QuartzCore/QuartzCore.h>


@interface ZPersonCell()

@property (nonatomic, assign) IBOutlet UIButton	*btnApprove;
@property (nonatomic, assign) IBOutlet UIButton	*btnDecline;

@end

@implementation ZPersonCell

- (void)awakeFromNib {
	UIFont *font = [UIFont fontWithName:@"RBNo3.1-Black" size:16];
	if (font) {
		_labTitle.font = font;
        
		_picBack.layer.masksToBounds = YES;
		_picBack.layer.cornerRadius = 4;
		_picBack.layer.borderColor = [UIColor grayColor].CGColor;
		_picBack.layer.borderWidth = 1;
        
        [self setButtonsVisible:NO];
	}
}

-(void)setButtonsVisible:(BOOL)value
{
    self.btnApprove.hidden = self.btnDecline.hidden = !value;
    
    [self setNeedsLayout];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect labelFrame = self.labTitle.frame;
    
    if(self.btnApprove.hidden)
    {
        labelFrame.size.width = 240;
    }
    else
    {
        labelFrame.size.width = 110;
    }
    
    self.labTitle.frame = labelFrame;
}

-(IBAction)approveAct
{
    [self.delegate cellApprovedFriend:self];
}

-(IBAction)declineAct
{
    [self.delegate cellDeclinedFriend:self];
}

+ (ZPersonCell *)cell {
	return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] lastObject];
}

@end

//
//  CustomTextTableViewCell_iPhone.m
//  Peek
//
//  Created by Pavel on 14.06.11.
//  Copyright 2011 Horns & Hoofs. All rights reserved.
//

#import "TextTableViewCell.h"
#import "ZSmartTextView.h"
#import "ZUserModel.h"
#import "NSAttributedString+Attributes.h"


@implementation TextTableViewCell
{
	CGFloat	initialHeight;
}

+ (TextTableViewCell *)cell {
	return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] lastObject];
}

- (void)awakeFromNib
{
    self.labelText.centerVertically = YES;
    self.labelText.delegate = self;
    self.labelText.userInteractionEnabled = YES;
    self.labelText.automaticallyAddLinksForType = NSTextCheckingTypeLink|NSTextCheckingTypeAddress;
    self.labelText.numberOfLines = 0;
    
    initialHeight = self.frame.size.height;
}

- (void)updateData:(int)ind
{
    index = ind;
    
    NSString *customStringFmt = [NSString stringWithFormat:@"ln%d", ind];
    NSString *customStringVisibleFmt = [NSString stringWithFormat:@"ln%d_v", ind];
    
    NSString *onValue = [self.userModel.customFields objectForKey:customStringVisibleFmt];
    NSString *textValue = [self.userModel.customFields objectForKey:customStringFmt];
    
    [self updateWithText:textValue];
   _switchTextField.on = [onValue boolValue];
	/*
	index = ind;
    
    NSString *smartText = [[self class] textAtIndex:index];
    
	[self.textField setSmartText:smartText];
	NSString *key = [NSString stringWithFormat:@"ln%d", index];
	key = [NSString stringWithFormat:@"%@_v", key];
    
    NSString *valueOn = [[NSUserDefaults standardUserDefaults] objectForKey:key];
	_switchTextField.on = [valueOn boolValue];
    */
}

-(void)updateWithText:(NSString*)text
{
    NSMutableAttributedString *attrStr = [NSMutableAttributedString attributedStringWithString:text];
    [attrStr setFont:self.labelText.font];
    
    if(self.textLabel.textAlignment == UITextAlignmentLeft)
    {
        CTTextAlignment textAlign = kCTTextAlignmentLeft;
        [attrStr setTextAlignment:textAlign lineBreakMode:kCTLineBreakByWordWrapping];
    }
    else
    {
        CTTextAlignment textAlign = kCTTextAlignmentCenter;
        [attrStr setTextAlignment:textAlign lineBreakMode:kCTLineBreakByWordWrapping];
    }

    self.labelText.attributedText = attrStr;

    [self setNeedsLayout];
}

- (void)updateDataWithText:(NSString*)text
{
    _switchTextField.hidden = YES;
	[self updateWithText:text];
}

- (IBAction)switchChanged:(UISwitch *)_switch
{
    if(index > 0)
    {
        NSString *customStringVisibleFmt = [NSString stringWithFormat:@"ln%d_v", index];
        [self.userModel.customFields setObject:[NSString stringWithFormat:@"%d", _switch.on] forKey:customStringVisibleFmt];
    }
}

-(CGFloat)heightForText:(NSString*)customText isSwitchVisible:(BOOL)isSwitchVisible
{
	if (!customText.length)
    {
		return initialHeight;
	}
    
    NSMutableAttributedString *attrStr = [NSMutableAttributedString attributedStringWithString:customText];
    [attrStr setFont:self.labelText.font];
    
    int labelWidth = 200;
    if(!isSwitchVisible)
        labelWidth = 300;
    CGSize maxSz = CGSizeMake(labelWidth, CGFLOAT_MAX);
    CGSize size = [attrStr sizeConstrainedToSize:maxSz];
    
    return MAX(size.height + 20, initialHeight);
}

- (CGFloat)heightForObject:(ZUserModel*)userModel atIndex:(int)indx isSwitchVisible:(BOOL)isSwitchVisible {
    
    NSString *customStringFmt = [NSString stringWithFormat:@"ln%d", indx];
	NSString *txt = [userModel.customFields objectForKey:customStringFmt];
	return [self heightForText:txt isSwitchVisible:isSwitchVisible];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect labelRect = self.labelText.frame;
    if(self.switchTextField.hidden)
    {
        labelRect.size.width = 300;
    }
    else
    {
        labelRect.size.width = 200;
    }
    
    self.labelText.frame = labelRect;
}

#pragma mark - OHAttributedLabel delegate

-(BOOL)attributedLabel:(OHAttributedLabel*)attributedLabel shouldFollowLink:(NSTextCheckingResult*)linkInfo
{
    if(attributedLabel == self.labelText)
    {
        [[UIApplication sharedApplication] openURL:linkInfo.URL];
    }
    
	return NO;
}


-(UIColor*)colorForLink:(NSTextCheckingResult*)link underlineStyle:(int32_t*)pUnderline {
    return [UIColor blackColor];
}

#pragma mark -

- (void)dealloc {
    [super dealloc];
}


@end

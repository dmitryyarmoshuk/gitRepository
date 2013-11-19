//
//  ZPersonPostCell.m
//  ZVeqtr
//
//  Created by Lee Loo on 10/23/12.
//  Copyright (c) 2012 PE-Leonid.Lo. All rights reserved.
//

#import "ZPersonPostCell.h"
#import <QuartzCore/QuartzCore.h>


@implementation ZPersonPostCell
{
	CGFloat		initialHeight;
}

- (void)awakeFromNib
{
	UIFont *font = [UIFont fontWithName:@"RBNo3.1-Black" size:16];
	if (font)
    {
		_labText.font = font;
        _labTitle.font = font;
		_picBack.layer.masksToBounds = YES;
		_picBack.layer.cornerRadius = 4;
		_picBack.layer.borderColor = [UIColor grayColor].CGColor;
		_picBack.layer.borderWidth = 1;
        
        self.picture.delegate = self;
	}
    
	initialHeight = self.frame.size.height;
}

+ (ZPersonPostCell *)cell {
	return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] lastObject];
}

- (CGFloat)heightWithText:(NSString *)txt hasImage:(BOOL)hasImage
{
	if (!txt.length) {
		return initialHeight;
	}
    
    int labelWidth = 250;
    if(!hasImage)
        labelWidth = 300;
    
	const CGSize maxSz = CGSizeMake(labelWidth, CGFLOAT_MAX);
	const CGSize size = [txt sizeWithFont:self.labText.font constrainedToSize:maxSz lineBreakMode:self.labText.lineBreakMode];

	return MAX(size.height + 5 + self.labText.frame.origin.y, initialHeight);
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect titleLabelFrame = self.labTitle.frame;
    CGRect textLabelFrame = self.labText.frame;
    if(self.picture.image == nil)
    {
        titleLabelFrame.size.width = 300;
        textLabelFrame.size.width = 300;
    }
    else
    {
        titleLabelFrame.size.width = 250;
        textLabelFrame.size.width = 250;
    }
    
    self.labTitle.frame = titleLabelFrame;
    self.labText.frame = textLabelFrame;
    
    //if(
}
       
- (void)imageViewLoadedImage:(EGOImageView*)imageView
{
    [self setNeedsLayout];
}

- (void)imageViewFailedToLoadImage:(EGOImageView*)imageView error:(NSError*)error
{
    [self setNeedsLayout];
}

@end

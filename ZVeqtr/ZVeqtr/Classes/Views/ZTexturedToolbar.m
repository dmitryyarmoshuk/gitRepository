//
//  ZTexturedToolbar.m
//  ZVeqtr
//
//  Created by Lee Loo on 10/18/12.
//  Copyright (c) 2012 PE-Leonid.Lo. All rights reserved.
//

#import "ZTexturedToolbar.h"

@implementation ZTexturedToolbar

@synthesize bgImage;
@synthesize title;

- (void)dealloc {
	self.bgImage = nil;
	self.title = nil;
	[super dealloc];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	
	if ((self = [super initWithCoder:aDecoder])) {
		
		CGRect labRect = CGRectMake(50, 0, 210, 44);
		UILabel *labTitle = [[UILabel alloc] initWithFrame:labRect];
		labTitle.backgroundColor = [UIColor clearColor];
		labTitle.textColor = [UIColor colorWithWhite:0.12 alpha:1];
		labTitle.font = [UIFont boldSystemFontOfSize:14];
		labTitle.shadowColor = [UIColor colorWithWhite:0.95 alpha:1];
		labTitle.shadowOffset = CGSizeMake(0, 1);
		labTitle.adjustsFontSizeToFitWidth = YES;
		labTitle.textAlignment = UITextAlignmentRight;
		
		self.title = labTitle;
		[labTitle release];
		
		[self addSubview:labTitle];
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
	
	UIImage *img = self.bgImage ? self.bgImage : [UIImage imageNamed:@"bar-top-navigation.png"];
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSaveGState(ctx);
	CGContextScaleCTM(ctx, 1, -1);
	CGContextTranslateCTM(ctx, 0, -rect.size.height);
	CGContextDrawImage(ctx, rect, img.CGImage);
	
	UIImage *imgLogo = [UIImage imageNamed:@"logo-icon-A.png"];
	CGRect logoRect = (CGRect){CGPointZero, imgLogo.size};
	logoRect.origin.x = rect.size.width - logoRect.size.width - 20;
	logoRect.origin.y = 0.5* (rect.size.height - logoRect.size.height);
	CGContextDrawImage(ctx, logoRect, imgLogo.CGImage);
	
	CGContextRestoreGState(ctx);
}

@end

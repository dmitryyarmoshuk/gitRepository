//
//  CustomBadge.h
//  ZVeqtr
//
//  Created by Maxim on 3/12/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomBadge : UIView {
    
    NSString *badgeText;
    UIColor *badgeTextColor;
    UIColor *badgeInsetColor;
    UIColor *badgeFrameColor;
    BOOL badgeFrame;
    CGFloat badgeCornerRoundness;
    
}

@property(nonatomic,retain) NSString *badgeText;
@property(nonatomic,retain) UIColor *badgeTextColor;
@property(nonatomic,retain) UIColor *badgeInsetColor;
@property(nonatomic,retain) UIColor *badgeFrameColor;
@property(nonatomic,readwrite) BOOL badgeFrame;
@property(nonatomic,readwrite) CGFloat badgeCornerRoundness;

+ (CustomBadge*) customBadgeWithString:(NSString *)badgeString;
+ (CustomBadge*) customBadgeWithString:(NSString *)badgeString withStringColor:(UIColor*)stringColor withInsetColor:(UIColor*)insetColor withBadgeFrame:(BOOL)badgeFrameYesNo withBadgeFrameColor:(UIColor*)frameColor;
- (void) autoBadgeSizeWithString:(NSString *)badgeString;

@end

//
//  ZTaggedButton.h
//  ZVeqtr
//
//  Created by Leonid Lo on 10/17/12.
//  Copyright (c) 2012 PE-Leonid.Lo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZTaggedButton : UIView
{}

@property (nonatomic, retain) id userInfo;

+ (ZTaggedButton *)buttonWithTarget:(id)target action:(SEL)action;

@end

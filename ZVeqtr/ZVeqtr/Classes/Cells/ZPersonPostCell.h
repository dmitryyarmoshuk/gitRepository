//
//  ZPersonPostCell.h
//  ZVeqtr
//
//  Created by Lee Loo on 10/23/12.
//  Copyright (c) 2012 PE-Leonid.Lo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"

@interface ZPersonPostCell : UITableViewCell<EGOImageViewDelegate>
{
}

+ (ZPersonPostCell *)cell;

@property (nonatomic, assign) IBOutlet UILabel	*labTitle;
@property (nonatomic, assign) IBOutlet UILabel	*labText;
@property (nonatomic, assign) IBOutlet UIView	*picBack;
@property (nonatomic, assign) IBOutlet EGOImageView *picture;

- (CGFloat)heightWithText:(NSString *)txt hasImage:(BOOL)hasImage;

@end

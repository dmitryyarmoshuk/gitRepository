//
//  ZMailListCell.h
//  ZVeqtr
//
//  Created by Maxim on 2/4/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EGOImageView;

@interface ZMailListCell : UITableViewCell

+ (ZMailListCell *)cell;

@property (nonatomic, assign) IBOutlet UILabel	*labTitle;
@property (nonatomic, assign) IBOutlet UILabel	*labNickname;
@property (nonatomic, assign) IBOutlet UIView	*picBack;
@property (nonatomic, assign) IBOutlet EGOImageView *picture;

@end

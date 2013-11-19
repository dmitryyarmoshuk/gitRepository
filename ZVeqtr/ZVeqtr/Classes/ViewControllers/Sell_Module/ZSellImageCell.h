//
//  ZSellImageCell.h
//  ZVeqtr
//
//  Created by Maxim on 4/4/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
#import "ZSellImageModel.h"

@interface ZSellImageCell : UITableViewCell<EGOImageViewDelegate>

@property (nonatomic, strong) IBOutlet UIButton *buttonChooseImage;
@property (nonatomic, strong) IBOutlet UIButton *buttonRemoveImage;
@property (nonatomic, strong) IBOutlet EGOImageView *cellImageView;

+ (ZSellImageCell *)cell;

-(void)updateWithSellImage:(ZSellImageModel*)model;

@end

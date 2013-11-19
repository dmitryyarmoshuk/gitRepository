//
//  ZSaleCell.h
//  ZVeqtr
//
//  Created by Maxim on 4/17/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZSaleCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *labelName;
@property (nonatomic, retain) IBOutlet UILabel *labelDescription;
@property (nonatomic, retain) IBOutlet UILabel *labelStatus;

+ (ZSaleCell *)cell;

@end

//
//  TextInputCell.h
//  ZVeqtr
//
//  Created by Maxim on 4/4/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextInputCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UITextField *textField;

+ (TextInputCell *)cell;

@end

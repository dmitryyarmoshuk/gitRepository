//
//  TimeFilterViewController.h
//  Peek
//
//  Created by Pavel on 16.09.11.
//  Copyright 2011 Horns & Hoofs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSuperViewController.h"


@class ZUserModel;

@interface TimeFilterViewController : ZSuperViewController
{
}

- (IBAction)actSelectSection:(id)sender;

@property (nonatomic, retain) ZUserModel *userModel;

@end

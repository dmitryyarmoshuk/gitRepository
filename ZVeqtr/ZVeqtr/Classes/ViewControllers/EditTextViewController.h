//
//  EditTextViewController
//  Peek
//
//  Created by Pavel on 29.06.11.
//  Copyright 2011 Horns & Hoofs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSuperViewController.h"

@class PeekAppDelegate;
@class ZUserModel;


@interface EditTextViewController : ZSuperViewController
{
	int index;
}

@property (nonatomic, retain) ZUserModel *userModel;
@property int index;

@end

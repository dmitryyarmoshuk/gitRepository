//
//  NewMessageViewController.h
//  Peek
//
//  Created by Pavel on 16.09.11.
//  Copyright 2011 Horns & Hoofs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZSuperViewController.h"

@protocol NewMessageViewControllerDelegate;

@interface NewMessageViewController : ZSuperViewController
<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>
{
}

@property (nonatomic, assign) id<NewMessageViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL isDirectMessage;

- (IBAction)buttonClearPressed;
- (IBAction)buttonCameraPressed;

@end


@class ZNewMessageModel;

@protocol NewMessageViewControllerDelegate <NSObject>
@required
- (void)newMessageViewController:(NewMessageViewController *)newMessageViewController
didFinishWithNewMessageModel:(ZNewMessageModel *)newMsgModel;
- (void)newMessageViewControllerDidCancel:(NewMessageViewController *)newMessageViewController;
@end

//
//  ZEmojiSelViewController.h
//  ZVeqtr
//
//  Created by Leonid Lo on 1/9/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import "ZSuperViewController.h"

@protocol ZEmojiSelViewControllerDelegate;


@interface ZEmojiSelViewController : ZSuperViewController
@property (nonatomic, assign) id<ZEmojiSelViewControllerDelegate> delegate;
@end


@protocol ZEmojiSelViewControllerDelegate <NSObject>
@required
- (void)emojiSelViewController:(ZEmojiSelViewController *)emojiSelViewController didSelectSymbol:(NSString *)strSymbol;
- (void)emojiSelViewControllerDidCancel:(ZEmojiSelViewController *)emojiSelViewController;
@end

//
//  ZEmojiCell.h
//  ZVeqtr
//
//  Created by Leonid Lo on 1/9/13.
//  Copyright (c) 2013 PE-Leonid.Lo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZEmojiCellDelegate;

@interface ZEmojiCell : UITableViewCell
@property (nonatomic, assign) IBOutlet	UIButton	*btn0, *btn1, *btn2, *btn3, *btn4;
+ (ZEmojiCell *)cell;
- (IBAction)actSelectEmoji:(id)sender;
@property (nonatomic, assign) id<ZEmojiCellDelegate> delegate;
@end


@protocol ZEmojiCellDelegate <NSObject>
- (void)emojiCell:(ZEmojiCell *)emojiCell didSelectSymbol:(NSString *)strSymbol;
@end

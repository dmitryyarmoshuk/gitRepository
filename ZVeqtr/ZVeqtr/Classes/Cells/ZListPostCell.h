//
//  ZPersonPostCell.h
//  ZVeqtr
//
//  Created by Lee Loo on 10/23/12.
//  Copyright (c) 2012 PE-Leonid.Lo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OHAttributedLabel.h"
#import "ZCopyableCell.h"

@class EGOImageView;
@class ZCommentOnMessageModel;
@protocol ZListPostCellDelegate;
@class ZConversationModel;

@interface ZListPostCell : ZCopyableCell <OHAttributedLabelDelegate, UIGestureRecognizerDelegate>
{
    __strong IBOutlet UIView	*_commentPicBack;
    __weak IBOutlet UIView *_menuView;
    __weak IBOutlet UIView *_messageView;
    __weak IBOutlet UILabel *_labelRate;
    
    __weak IBOutlet UIButton *_toMapButton;
    __weak IBOutlet UIButton *_pictureButton;
}

+ (ZListPostCell *)cell;

@property (nonatomic, assign) IBOutlet OHAttributedLabel	*labMessage;
@property (nonatomic, assign) IBOutlet UIView	*picBack;
@property (nonatomic, assign) IBOutlet EGOImageView *picture;


@property (nonatomic, assign) IBOutlet EGOImageView *commentPicture;

@property (nonatomic, assign) id<ZListPostCellDelegate> delegate;
@property (nonatomic, retain) ZCommentOnMessageModel	*commentModel;

@property (nonatomic, assign) BOOL	isDirectMessage;
@property (nonatomic, assign) BOOL	isVenueMessage;

- (CGFloat)heightWithCommentModel:(ZCommentOnMessageModel *)commentModel andInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

-(void)applyVenueConversationModel:(ZConversationModel*)model;
-(void)showMenu:(BOOL)show animated:(BOOL)animated;
-(BOOL)isMenuOpened;

@end


@protocol ZListPostCellDelegate <NSObject>
@required
- (BOOL)listPostCellShouldShowMenu:(ZListPostCell *)listPostCell;
- (void)listPostCellDidClickMessageImage:(ZListPostCell *)listPostCell;
- (void)listPostCellDidClickUsername:(ZListPostCell *)listPostCell;
- (void)listPostCellDidClickVoteDown:(ZListPostCell *)listPostCell;
- (void)listPostCellDidClickMail:(ZListPostCell *)listPostCell;
- (void)listPostCellDidClickFlag:(ZListPostCell *)listPostCell;
- (void)listPostCellDidClickToMap:(ZListPostCell *)listPostCell;
- (void)listPostCellDidClickVoteUp:(ZListPostCell *)listPostCell;
- (void)listPostCellDidTouched:(ZListPostCell *)listPostCell;
- (void)listPostCell:(ZListPostCell *)listPostCell didClickUsernameLink:(NSString*)username;

@end

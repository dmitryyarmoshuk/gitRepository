//
//  ZPersonPostCell.m
//  ZVeqtr
//
//  Created by Lee Loo on 10/23/12.
//  Copyright (c) 2012 PE-Leonid.Lo. All rights reserved.
//

#import "ZListPostCell.h"
#import <QuartzCore/QuartzCore.h>
#import "ZCommentOnMessageModel.h"
#import "EGOImageView.h"
#import "NSURL+ZVeqtr.h"
#import "NSAttributedString+Attributes.h"
#import "ZConversationModel.h"


#define MESSAGE_FONT [UIFont fontWithName:@"RBNo3.1-Black" size:16]

@interface ZListPostCell ()
@property (nonatomic, retain) ZCommentOnMessageModel	*internalCommModel;
@end

@implementation ZListPostCell {
	CGFloat	initialHeight;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
	UIFont *font = MESSAGE_FONT;
	if (font) {
		_labMessage.font = font;

		_picBack.layer.masksToBounds = YES;
		_picBack.layer.cornerRadius = 4;
		_picBack.layer.borderColor = [UIColor yellowColor].CGColor;
		_picBack.layer.borderWidth = 3;
        
        _commentPicBack.layer.masksToBounds = YES;
		_commentPicBack.layer.cornerRadius = 4;
		_commentPicBack.layer.borderColor = [UIColor grayColor].CGColor;
		_commentPicBack.layer.borderWidth = 1;
        
        //self.labMessage.backgroundColor = [UIColor clearColor];
        self.labMessage.centerVertically = YES;
        self.labMessage.textAlignment = UITextAlignmentCenter;
        self.labMessage.delegate = self;
        self.labMessage.userInteractionEnabled = YES;
        self.labMessage.automaticallyAddLinksForType = NSTextCheckingTypeLink|NSTextCheckingTypeAddress;
        self.labMessage.numberOfLines = 0;
        
        [self showMenu:NO animated:NO];
	}
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
	initialHeight = self.frame.size.height;
}

-(IBAction)btnToMap_Clicked
{
    if(self.delegate)
    {
        [self.delegate listPostCellDidClickToMap:self];
    }
}

-(IBAction)btnUsername_Clicked
{
    if(self.delegate)
    {
        [self.delegate listPostCellDidClickUsername:self];
    }
}

-(IBAction)voteDown_Clicked
{

    if(self.delegate)
    {
        [self.delegate listPostCellDidClickVoteDown:self];
    }
}

-(IBAction)mail_Clicked
{

    if(self.delegate)
    {
        [self.delegate listPostCellDidClickMail:self];
    }
}

-(IBAction)flag_Clicked
{

    if(self.delegate)
    {
        [self.delegate listPostCellDidClickFlag:self];
    }
}

-(IBAction)voteUp_Clicked
{
    
    if(self.delegate)
    {
        [self.delegate listPostCellDidClickVoteUp:self];
    }
}

-(IBAction)cellPressed
{
    if(self.delegate)
       [self.delegate listPostCellDidTouched:self];
    
    if([self isMenuOpened])
    {
        [self showMenu:NO animated:YES];
    }
    else
    {
        [self showMenu:YES animated:YES];
    }
}

-(IBAction)swipeRight
{
    if(self.delegate)
        [self.delegate listPostCellDidTouched:self];
    
    if(![self isMenuOpened])
    {
        [self showMenu:YES animated:YES];
    }
}

-(BOOL)isMenuOpened
{
    NSLog(@"%@: %@", self.commentModel.ID, NSStringFromCGRect(_messageView.frame));
    return _messageView.frame.origin.x > 0;
}

-(void)setMenuOffset:(float)offset
{
    CGRect menuFrame = _menuView.frame;
    menuFrame.origin.x = offset;
    _menuView.frame = menuFrame;
    
    CGRect msgContent = _messageView.frame;
    msgContent.origin.x = offset + _menuView.frame.size.width;
    msgContent.size.width = self.contentView.frame.size.width - msgContent.origin.x;
    _messageView.frame = msgContent;
}

-(void)showMenu:(BOOL)show animated:(BOOL)animated
{
    if(show)
    {
        if(self.delegate && ![self.delegate listPostCellShouldShowMenu:self])
            return;
        
        if(animated)
        {
            [UIView animateWithDuration:0.2 animations:^(void)
             {
                 [self setMenuOffset:0];
             }];
        }
        else
        {
            [self setMenuOffset:0];
        }
        
    }
    else
    {
        if(animated)
        {
            [UIView animateWithDuration:0.2 animations:^(void)
             {
                 [self setMenuOffset:-_menuView.frame.size.width];
             }];
        }
        else
        {
            [self setMenuOffset:-_menuView.frame.size.width];
        }
    }
    
}

- (void)dealloc {
	self.internalCommModel = nil;
	[super dealloc];
}

+ (ZListPostCell *)cell {
	return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] objectAtIndex:0];
}

- (void)setCommentModel:(ZCommentOnMessageModel *)commentModel {
	self.internalCommModel = commentModel;
	[self applyModel];
}

- (ZCommentOnMessageModel *)commentModel {
	return self.internalCommModel;
}

- (IBAction)buttonFbShare_Action:(id)sender
{
    NSString *imageUrl = nil;
     if(self.internalCommModel.hasImage)
     {
         NSURL *url = [NSURL urlThumbMailImageWithID:self.internalCommModel.ID];
         imageUrl = [url absoluteString];
     }
    
    NSLog(@"%@", imageUrl);
    
//zsf    [FBShareUtils shareText:self.internalCommModel.text imageUrl:imageUrl];
}

-(NSMutableArray*)usernamesFromString:(NSString*)commentString
{
    NSMutableArray *array = [NSMutableArray array];
    
    while (commentString.length > 0)
    {
        NSRange range = [commentString rangeOfString:@"%@"];
        
        if(range.length == 0)
            return array;
        
        commentString = [commentString substringFromIndex:range.location];
        range = [commentString rangeOfString:@" "];
        int location = range.location > 0 ? range.location : commentString.length;
        
        NSString *username = [commentString substringToIndex:location];
        
        [array addObject:username];
        
        commentString = [commentString substringToIndex:location];
    }
    
    return array;
}

- (void)applyModel
{
    NSMutableAttributedString *attrStr = [NSMutableAttributedString attributedStringWithString:self.internalCommModel.text];
    [attrStr setFont:self.labMessage.font];
	self.labMessage.attributedText = attrStr;
    
    if(self.internalCommModel.text)
    {
        NSString *commentString = [NSString stringWithString:self.internalCommModel.text];
        int length = 0;
        while (commentString.length > 0)
        {
            NSRange range = [commentString rangeOfString:@"@"];
            
            if(range.length == 0)
                break;
            
            commentString = [commentString substringFromIndex:range.location];
            length += range.location;
            
            range = [commentString rangeOfString:@" "];
            int location = range.length > 0 ? range.location : commentString.length;
            
            NSString *username = [commentString substringToIndex:location];
            
            //NSRange range = [NSRange mak]
            
            [self.labMessage addCustomLink:[NSURL URLWithString:username] inRange:NSMakeRange(length, username.length)];
            
            commentString = [commentString substringFromIndex:location];
            length += location;
        }
    }
    
	NSString *rating = self.internalCommModel.rating;

	const int nrate = [rating intValue];
    if(nrate > 0)
    {
         _picBack.layer.borderColor = [UIColor yellowColor].CGColor;
        _labelRate.textColor = [UIColor yellowColor];
        _labelRate.hidden = NO;
        _labelRate.text = rating;
    }
    else if(nrate < 0)
    {
        _picBack.layer.borderColor = [UIColor redColor].CGColor;
        _labelRate.textColor = [UIColor redColor];
        _labelRate.hidden = NO;
        _labelRate.text = rating;
    }
    else
    {
        _picBack.layer.borderColor = [UIColor blackColor].CGColor;
        _labelRate.hidden = YES;
    }
    
	self.picture.imageURL = [NSURL urlPersonProfileImageWithID:self.internalCommModel.userID];
    if(self.internalCommModel.hasImage)
    {
        self.commentPicture.imageURL = self.isVenueMessage ? [NSURL urlThumbVenueMessageImageWithID:self.internalCommModel.ID] : [NSURL urlThumbMailImageWithID:self.internalCommModel.ID];
        NSLog(@"%@", self.commentPicture.imageURL);
        self.accessoryView = _commentPicBack;
    }
    else
    {
        self.accessoryView = nil;
    }
}

-(void)applyVenueConversationModel:(ZConversationModel*)model
{
    NSMutableAttributedString *attrStr = [NSMutableAttributedString attributedStringWithString:model.title];
    [attrStr setFont:self.labMessage.font];
    
	self.labMessage.attributedText = attrStr;
	
	_labelRate.hidden = YES;
    
	self.picture.imageURL = [NSURL urlPersonProfileImageWithID:model.user_id];
   
    self.accessoryView = nil;
}

- (CGFloat)heightWithCommentModel:(ZCommentOnMessageModel *)commentModel andInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    float externalSpace = 70;
    float accessoryViewWidth = 40;
    
    int messageLabelWidth = UIInterfaceOrientationIsPortrait(interfaceOrientation) ? 320 - externalSpace : 480 - externalSpace;
    
    if(commentModel.hasImage)
    {
        messageLabelWidth -= accessoryViewWidth;
    }
    
	NSString *txt = commentModel.text;
    
	if (!txt.length)
    {
		return initialHeight;
	}
    
    NSMutableAttributedString *attrStr = [NSMutableAttributedString attributedStringWithString:commentModel.text];
    [attrStr setFont:MESSAGE_FONT];
    
    CGSize maxSz = CGSizeMake(messageLabelWidth, CGFLOAT_MAX);
    CGSize size = [attrStr sizeConstrainedToSize:maxSz];
    
    return MAX(size.height + 10, initialHeight);
}

#pragma mark - UIGesture Recognizer delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if(touch.view == _pictureButton
       || touch.view == _toMapButton)
        return NO;
    
    return YES;
    
    return ! ([touch.view isKindOfClass:[UIButton class]]);
}

#pragma mark - Events

- (IBAction)actShowImage:(UIButton *)sender {
	[self.delegate listPostCellDidClickMessageImage:self];
}

#pragma mark - OHAttributedLabel delegate

-(BOOL)attributedLabel:(OHAttributedLabel*)attributedLabel shouldFollowLink:(NSTextCheckingResult*)linkInfo
{
    /*
     currentUrl = [linkInfo.URL retain];
     
     UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:nil
     message:@"This link will open in Safari"
     delegate:self
     cancelButtonTitle:nil
     otherButtonTitles:@"Cancel", @"Yes", nil] autorelease];
     [alert show];
     */
    if(attributedLabel == self.labMessage)
    {
        NSLog(@"%@", linkInfo);
        
        NSString *urlString = [linkInfo.URL absoluteString];
        NSRange range = [urlString rangeOfString:@"@"];
        if(range.length > 0)
        {
            //this is link for username
            if(self.delegate)
                [self.delegate listPostCell:self didClickUsernameLink:[urlString substringFromIndex:1]];
        }
        else
        {
            //this is simple link
            [[UIApplication sharedApplication] openURL:linkInfo.URL];
        }
        
        
        //[self.delegate notificationCellUsernameClicked:self];
    }
    
	return NO;
}

-(UIColor*)colorForLink:(NSTextCheckingResult*)link underlineStyle:(int32_t*)pUnderline {
    return [UIColor blackColor];
}

@end
